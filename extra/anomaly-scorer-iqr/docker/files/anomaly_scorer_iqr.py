#!/usr/bin/env python3
"""IQR-band anomaly scorer.

Polls a Prometheus-compatible API for a range query, builds a robust
interquartile-range (Tukey-fence) band from each series' training window, scores
how far the trailing points fall outside that band, and exposes the worst-point
score per series as a Prometheus gauge.

A training-free, seasonality-naive companion to the Prophet `anomaly-scorer`: no
model fit and robust to outliers in the baseline, but it treats a strongly
cyclic signal's normal peaks as deviations — reach for it on flat-ish / noisy
metrics. Every knob is an environment variable (see README.md).
"""
import logging
import os
import time

import pandas as pd
import requests
from prometheus_client import Gauge, start_http_server


def _env(name, default):
    return os.environ.get(name, default)


PROMETHEUS_URL   = _env("PROMETHEUS_URL", "http://prometheus-operated.monitoring.svc:9090").rstrip("/")
METRIC_QUERY     = _env("METRIC_QUERY", 'container_memory_working_set_bytes{namespace="production"}')
ANOMALY_LABELS   = [s.strip() for s in _env("ANOMALY_LABELS", "namespace,pod").split(",") if s.strip()]
LOOKBACK_DAYS    = float(_env("LOOKBACK_DAYS", "7"))
STEP             = _env("STEP", "5m")
EVAL_POINTS      = int(_env("EVAL_POINTS", "12"))
IQR_K            = float(_env("IQR_K", "1.5"))       # Tukey fence multiplier
LOOP_INTERVAL    = int(_env("LOOP_INTERVAL", "300"))
EXPORTER_PORT    = int(_env("EXPORTER_PORT", "8000"))
METRIC_NAME      = _env("METRIC_NAME", "custom_anomaly_score")
PROM_TENANT      = _env("PROM_TENANT", "")           # X-Scope-OrgID for Mimir/Cortex
PROM_TOKEN       = _env("PROM_TOKEN", "")            # bearer token
MIN_TRAIN_POINTS = int(_env("MIN_TRAIN_POINTS", "30"))
LOG_LEVEL        = _env("LOG_LEVEL", "INFO").upper()

logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("anomaly-scorer-iqr")

ANOMALY_SCORE = Gauge(METRIC_NAME, "IQR-band anomaly score for a metric series", ANOMALY_LABELS)


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
    """Worst-point Tukey-fence deviation over the trailing EVAL_POINTS window.

    0.0   -> every scored point sits inside [Q1 - k*IQR, Q3 + k*IQR];
    ->1.0 -> a point is a full fence-width (or more) outside it.

    Q1/Q3/IQR come from the training window (all but the trailing EVAL_POINTS),
    so the most recent points are scored against an unspoiled baseline.
    """
    df = pd.DataFrame(values, columns=["ds", "y"])
    df["y"] = df["y"].astype(float)

    if len(df) < MIN_TRAIN_POINTS + EVAL_POINTS:
        raise ValueError(f"not enough points ({len(df)} < {MIN_TRAIN_POINTS + EVAL_POINTS})")

    train = df["y"].iloc[:-EVAL_POINTS]      # baseline window
    tail = df["y"].iloc[-EVAL_POINTS:]       # scored window

    q1 = train.quantile(0.25)
    q3 = train.quantile(0.75)
    iqr = q3 - q1
    lower = q1 - IQR_K * iqr
    upper = q3 + IQR_K * iqr
    band_width = (upper - lower) if upper != lower else 1.0  # guard a flat series

    scores = []
    for a in tail:
        if lower <= a <= upper:
            scores.append(0.0)
        else:
            deviation = max(lower - a, a - upper)
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
        "exporter on :%d - IQR-scoring %r every %ds (lookback=%sd step=%s eval=%d k=%s)",
        EXPORTER_PORT, METRIC_QUERY, LOOP_INTERVAL, LOOKBACK_DAYS, STEP, EVAL_POINTS, IQR_K,
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
