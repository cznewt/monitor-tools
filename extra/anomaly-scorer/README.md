# anomaly-scorer

A small Prophet-based anomaly **scorer** for Prometheus metrics. It periodically
range-queries a metric, fits a [Prophet](https://facebook.github.io/prophet/)
model per returned series, measures how far the latest points fall outside the
model's predicted uncertainty band, and re-exports the worst-point score per
series as a Prometheus gauge you can alert on.

It is the packaged, parameterized form of the walk-through in
[`notebooks/analysis-anomaly-detection.ipynb`](../../notebooks/analysis-anomaly-detection.ipynb).

## How it works

Every `LOOP_INTERVAL` seconds:

1. `GET /api/v1/query_range` for `METRIC_QUERY` over the last `LOOKBACK_DAYS` at
   `STEP` resolution.
2. For each returned series, fit Prophet on all but the trailing `EVAL_POINTS`
   samples, then predict that held-out window.
3. Score each held-out point: `0.0` inside the `[yhat_lower, yhat_upper]` band,
   otherwise its distance outside as a fraction of the band width (capped at
   `1.0`).
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
| `LOOKBACK_DAYS` | `7` | Days of history to train on. |
| `STEP` | `5m` | Query resolution. |
| `EVAL_POINTS` | `12` | Trailing points to hold out and score (12 x 5m = 1h). |
| `INTERVAL_WIDTH` | `0.95` | Prophet uncertainty-band width. |
| `DAILY_SEASONALITY` | `true` | `auto` / `true` / `false` / integer Fourier terms. |
| `WEEKLY_SEASONALITY` | `auto` | Same accepted values as above. |
| `MIN_TRAIN_POINTS` | `30` | Skip series with fewer than this many training points. |
| `LOOP_INTERVAL` | `300` | Seconds between scrape cycles. |
| `EXPORTER_PORT` | `8000` | Port for the `/metrics` endpoint. |
| `METRIC_NAME` | `custom_anomaly_score` | Name of the exported gauge. |
| `PROM_TENANT` | _(empty)_ | `X-Scope-OrgID` header (Mimir/Cortex multitenancy). |
| `PROM_TOKEN` | _(empty)_ | Bearer token for the query API. |
| `LOG_LEVEL` | `INFO` | Python log level. |

> Keep `ANOMALY_LABELS` aligned with the label dimensions your `METRIC_QUERY`
> actually returns, or several series will collapse onto the same gauge.

## Run

With Compose:

```bash
docker compose up --build
curl -s localhost:8000/metrics | grep custom_anomaly_score
```

Or directly:

```bash
docker build -t anomaly-scorer ./docker
docker run --rm -p 8000:8000 \
  -e PROMETHEUS_URL=http://host.docker.internal:9090 \
  -e METRIC_QUERY='sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))' \
  -e ANOMALY_LABELS=pod \
  anomaly-scorer
```

## Alert on it

Once Prometheus scrapes the exporter, the score is just another metric:

```yaml
groups:
  - name: anomaly-scorer
    rules:
      - alert: MetricAnomalyDetected
        expr: custom_anomaly_score > 0.8
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Anomaly on {{ $labels.namespace }}/{{ $labels.pod }} (score {{ $value | printf `%.2f` }})"
```
