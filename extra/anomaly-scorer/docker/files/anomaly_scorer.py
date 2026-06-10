#!/usr/bin/env python3
"""Prophet-based anomaly scorer.

Polls a Prometheus-compatible API for a range query, fits a Prophet model per
returned series on all-but-the-trailing window, scores how far the actual
trailing points fall outside Prophet's predicted uncertainty band, and exposes
the worst-point score per series as a Prometheus gauge.

Every knob is an environment variable (see README.md); the defaults reproduce
the original single-namespace memory example.
"""
import logging
import os
import time

import pandas as pd
import requests
from prometheus_client import Gauge, start_http_server
from prophet import Prophet


def _env(name, default):
    return os.environ.get(name, default)


def _parse_seasonality(value):
    """Prophet seasonality flag: 'auto', a bool, or an int number of terms."""
    v = str(value).strip().lower()
    if v == "auto":
        return "auto"
    if v in ("true", "1", "yes", "on"):
        return True
    if v in ("false", "0", "no", "off", ""):
        return False
    return int(v)


PROMETHEUS_URL     = _env("PROMETHEUS_URL", "http://prometheus-operated.monitoring.svc:9090").rstrip("/")
METRIC_QUERY       = _env("METRIC_QUERY", 'container_memory_working_set_bytes{namespace="production"}')
ANOMALY_LABELS     = [s.strip() for s in _env("ANOMALY_LABELS", "namespace,pod").split(",") if s.strip()]
LOOKBACK_DAYS      = float(_env("LOOKBACK_DAYS", "7"))
STEP               = _env("STEP", "5m")
EVAL_POINTS        = int(_env("EVAL_POINTS", "12"))
INTERVAL_WIDTH     = float(_env("INTERVAL_WIDTH", "0.95"))
DAILY_SEASONALITY  = _parse_seasonality(_env("DAILY_SEASONALITY", "true"))
WEEKLY_SEASONALITY = _parse_seasonality(_env("WEEKLY_SEASONALITY", "auto"))
LOOP_INTERVAL      = int(_env("LOOP_INTERVAL", "300"))
EXPORTER_PORT      = int(_env("EXPORTER_PORT", "8000"))
METRIC_NAME        = _env("METRIC_NAME", "custom_anomaly_score")
PROM_TENANT        = _env("PROM_TENANT", "")       # X-Scope-OrgID for Mimir/Cortex
PROM_TOKEN         = _env("PROM_TOKEN", "")         # bearer token
MIN_TRAIN_POINTS   = int(_env("MIN_TRAIN_POINTS", "30"))
LOG_LEVEL          = _env("LOG_LEVEL", "INFO").upper()

logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s %(message)s")
logging.getLogger("cmdstanpy").setLevel(logging.WARNING)  # silence the fitter
log = logging.getLogger("anomaly-scorer")

ANOMALY_SCORE = Gauge(METRIC_NAME, "Prophet anomaly score for a metric series", ANOMALY_LABELS)


def _headers():
    h = {}
    if PROM_TENANT:
        h["X-Scope-OrgID"] = PROM_TENANT
    if PROM_TOKEN:
        h["Authorization"] = f"Bearer {PROM_TOKEN}"
    return h


def fetch_metric(query, lookback_days=LOOKBACK_DAYS, step=STEP):
    end = int(time.time())
    start = end - int(lookback_days * 86400)
    resp = requests.get(
        f"{PROMETHEUS_URL}/api/v1/query_range",
        params={"query": query, "start": start, "end": end, "step": step},
        headers=_headers(),
        timeout=120,
    )
    resp.raise_for_status()
    payload = resp.json()
    if payload.get("status") != "success":
        raise RuntimeError(f"query failed: {payload.get('error', payload)}")
    return payload["data"]["result"]


def compute_anomaly_score(values):
    """Worst-point band-deviation score over the trailing EVAL_POINTS window.

    0.0   -> every scored point sits inside Prophet's predicted band;
    ->1.0 -> a point is a full band-width (or more) outside it.
    """
    df = pd.DataFrame(values, columns=["ds", "y"])
    df["ds"] = pd.to_datetime(df["ds"], unit="s")
    df["y"] = df["y"].astype(float)

    if len(df) < MIN_TRAIN_POINTS + EVAL_POINTS:
        raise ValueError(f"not enough points ({len(df)} < {MIN_TRAIN_POINTS + EVAL_POINTS})")

    model = Prophet(
        interval_width=INTERVAL_WIDTH,
        daily_seasonality=DAILY_SEASONALITY,
        weekly_seasonality=WEEKLY_SEASONALITY,
    )
    model.fit(df.iloc[:-EVAL_POINTS])  # train on all but the trailing window

    forecast = model.predict(df.tail(EVAL_POINTS)[["ds"]])
    actual = df.tail(EVAL_POINTS)["y"].values
    lower = forecast["yhat_lower"].values
    upper = forecast["yhat_upper"].values

    scores = []
    for a, l, u in zip(actual, lower, upper):
        if l <= a <= u:
            scores.append(0.0)
        else:
            deviation = max(l - a, a - u)
            band_width = (u - l) if u != l else 1.0
            scores.append(min(deviation / band_width, 1.0))
    return max(scores) if scores else 0.0


def _set_score(label_values, score):
    if ANOMALY_LABELS:
        ANOMALY_SCORE.labels(**label_values).set(score)
    else:
        ANOMALY_SCORE.set(score)


def scrape_once():
    results = fetch_metric(METRIC_QUERY)
    scored = 0
    for result in results:
        metric = result.get("metric", {})
        label_values = {k: metric.get(k, "") for k in ANOMALY_LABELS}
        try:
            score = compute_anomaly_score(result["values"])
        except Exception as exc:  # one bad series must not stop the rest
            log.warning("skip series %s: %s", label_values or metric, exc)
            continue
        _set_score(label_values, score)
        scored += 1
        log.debug("scored %s -> %.3f", label_values, score)
    log.info("scored %d/%d series", scored, len(results))


def main():
    log.info(
        "exporter on :%d - scoring %r every %ds (lookback=%sd step=%s eval=%d)",
        EXPORTER_PORT, METRIC_QUERY, LOOP_INTERVAL, LOOKBACK_DAYS, STEP, EVAL_POINTS,
    )
    start_http_server(EXPORTER_PORT)
    while True:
        try:
            scrape_once()
        except Exception as exc:
            log.error("scrape cycle failed: %s", exc)
        time.sleep(LOOP_INTERVAL)


if __name__ == "__main__":
    main()
