# anomaly-scorer-iqr

A small **IQR-band** anomaly scorer for Prometheus metrics. It periodically
range-queries a metric, builds a robust [interquartile-range][iqr] (Tukey-fence)
band per returned series from the training window, measures how far the latest
points fall outside that band, and re-exports the worst-point score per series
as a Prometheus gauge you can alert on.

It is the training-free, seasonality-naive sibling of [`anomaly-scorer`](../anomaly-scorer/)
(Prophet) and [`anomaly-scorer-zscore`](../anomaly-scorer-zscore/) (robust
z-score). Same query → score → export shape; no model fit and no Prophet
dependency, which makes it fast and dependency-light — but it has no notion of
trend or seasonality, so a strongly cyclic signal's normal peaks will read as
deviations. Reach for it on flat-ish or noisy metrics.

[iqr]: https://en.wikipedia.org/wiki/Interquartile_range#Outliers

## How it works

Every `LOOP_INTERVAL` seconds:

1. `GET /api/v1/query_range` for `METRIC_QUERY` over the last `LOOKBACK_DAYS` at
   `STEP` resolution.
2. For each returned series, take `Q1`, `Q3` and `IQR = Q3 - Q1` over all but the
   trailing `EVAL_POINTS` samples, and form the fence `[Q1 - k·IQR, Q3 + k·IQR]`
   (`k = IQR_K`).
3. Score each trailing point: `0.0` inside the fence, otherwise its distance
   outside as a fraction of the fence width (capped at `1.0`).
4. Publish the series' worst point as `METRIC_NAME` (default
   `custom_anomaly_score`), labelled by `ANOMALY_LABELS`, on
   `:EXPORTER_PORT/metrics`.

A series with fewer than `MIN_TRAIN_POINTS + EVAL_POINTS` samples is skipped, and
a failure on one series never stops the others.

## Configuration

All configuration is via environment variables:

| Variable | Default | Description |
| :--- | :--- | :--- |
| `PROMETHEUS_URL` | `http://prometheus-operated.monitoring.svc:9090` | Base URL of a Prometheus-compatible API. |
| `METRIC_QUERY` | `container_memory_working_set_bytes{namespace="production"}` | PromQL range query to score. |
| `ANOMALY_LABELS` | `namespace,pod` | Comma-separated label keys copied from each series onto the exported gauge. |
| `LOOKBACK_DAYS` | `7` | Days of history to build the baseline on. |
| `STEP` | `5m` | Query resolution. |
| `EVAL_POINTS` | `12` | Trailing points to hold out and score (12 x 5m = 1h). |
| `IQR_K` | `1.5` | Tukey fence multiplier; `1.5` ≈ mild outliers, `3.0` ≈ far outliers. |
| `MIN_TRAIN_POINTS` | `30` | Skip series with fewer than this many baseline points. |
| `LOOP_INTERVAL` | `300` | Seconds between scrape cycles. |
| `EXPORTER_PORT` | `8000` | Port for the `/metrics` endpoint. |
| `METRIC_NAME` | `custom_anomaly_score` | Name of the exported gauge. |
| `PROM_TENANT` | _(empty)_ | `X-Scope-OrgID` header (Mimir/Cortex multitenancy). |
| `PROM_TOKEN` | _(empty)_ | Bearer token for the query API. |
| `LOG_LEVEL` | `INFO` | Python log level. |

> Keep `ANOMALY_LABELS` aligned with the label dimensions your `METRIC_QUERY`
> actually returns, or several series will collapse onto the same gauge. If you
> run more than one scorer against the same Prometheus, give each a distinct
> `METRIC_NAME` (e.g. `custom_anomaly_score_iqr`) so they don't overwrite.

## Run

With Compose:

```bash
docker compose up --build
curl -s localhost:8000/metrics | grep custom_anomaly_score
```

Or directly:

```bash
docker build -t anomaly-scorer-iqr ./docker
docker run --rm -p 8000:8000 \
  -e PROMETHEUS_URL=http://host.docker.internal:9090 \
  -e METRIC_QUERY='sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))' \
  -e ANOMALY_LABELS=pod \
  anomaly-scorer-iqr
```

## Alert on it

Once Prometheus scrapes the exporter, the score is just another metric:

```yaml
groups:
  - name: anomaly-scorer-iqr
    rules:
      - alert: MetricAnomalyDetected
        expr: custom_anomaly_score > 0.8
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Anomaly on {{ $labels.namespace }}/{{ $labels.pod }} (score {{ $value | printf `%.2f` }})"
```
