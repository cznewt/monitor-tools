# anomaly-scorer-zscore

A small **robust z-score** anomaly scorer for Prometheus metrics. It periodically
range-queries a metric, builds an outlier-resistant baseline (median +
[median-absolute-deviation][mad]) per returned series from the training window,
measures how many robust standard deviations the latest points sit from it, and
re-exports the worst-point score per series as a Prometheus gauge you can alert
on.

It is the smooth-gradient sibling of [`anomaly-scorer`](../anomaly-scorer/)
(Prophet) and [`anomaly-scorer-iqr`](../anomaly-scorer-iqr/) (IQR fence). Same
query → score → export shape; MAD keeps the baseline robust to spikes, and the
score is a continuous ramp rather than an in/out band — handy when you want
severity, not just a yes/no. Like the IQR scorer it has no notion of trend or
seasonality, so a strongly cyclic signal's normal peaks will read as deviations;
reach for it on flat-ish or noisy metrics.

[mad]: https://en.wikipedia.org/wiki/Median_absolute_deviation

## How it works

Every `LOOP_INTERVAL` seconds:

1. `GET /api/v1/query_range` for `METRIC_QUERY` over the last `LOOKBACK_DAYS` at
   `STEP` resolution.
2. For each returned series, take the `median` and `MAD` over all but the
   trailing `EVAL_POINTS` samples; the robust sigma is `1.4826 · MAD`.
3. Score each trailing point: `min(|y − median| / (1.4826·MAD) / Z_MAX, 1.0)` —
   `0.0` on the median, `1.0` once it is `Z_MAX` robust-sigmas away.
4. Publish the series' worst point as `METRIC_NAME` (default
   `custom_anomaly_score`), labelled by `ANOMALY_LABELS`, on
   `:EXPORTER_PORT/metrics`.

If a baseline is near-constant (MAD collapses to 0) the scorer falls back to the
window's standard deviation, then to a neutral scale, so a flat series never
divides by zero. A series with fewer than `MIN_TRAIN_POINTS + EVAL_POINTS`
samples is skipped, and a failure on one series never stops the others.

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
| `Z_MAX` | `4` | Robust z-score that maps to a full `1.0`; lower = more sensitive. |
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
> `METRIC_NAME` (e.g. `custom_anomaly_score_zscore`) so they don't overwrite.

## Run

With Compose:

```bash
docker compose up --build
curl -s localhost:8000/metrics | grep custom_anomaly_score
```

Or directly:

```bash
docker build -t anomaly-scorer-zscore ./docker
docker run --rm -p 8000:8000 \
  -e PROMETHEUS_URL=http://host.docker.internal:9090 \
  -e METRIC_QUERY='sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))' \
  -e ANOMALY_LABELS=pod \
  anomaly-scorer-zscore
```

## Alert on it

Once Prometheus scrapes the exporter, the score is just another metric:

```yaml
groups:
  - name: anomaly-scorer-zscore
    rules:
      - alert: MetricAnomalyDetected
        expr: custom_anomaly_score > 0.8
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Anomaly on {{ $labels.namespace }}/{{ $labels.pod }} (score {{ $value | printf `%.2f` }})"
```
