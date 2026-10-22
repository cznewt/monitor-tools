# Demo app containers

The `demo-apps` chart runs two kinds of containers:

- **Nine app images**, one per signal and runtime, built from
  [`extra/app-instrumentation`](https://github.com/cznewt/monitor-tools/tree/main/extra/app-instrumentation).
- **Three generators**, which are plain Python scripts on a stock image.

This page covers what is inside each container and how to build a new image
tag. [Usage](demo-apps.md) covers installing the chart, and the
[Chart reference](demo-apps-chart.md) lists its values.

## Where the images live

- **Name and tag:** `ghcr.io/cznewt/demo-<logging|metrics-prom|traces>-<go|python|rust>:<tag>`.
  All nine share one tag. The current one is `2026.09-r1`, which is the
  chart's `imageTag` default and its `appVersion`.
- **Private:** ghcr refuses anonymous pulls of all nine (checked 2026-10-22).
  A cluster needs a pull secret, passed as `imagePullSecrets`:

    ```sh
    kubectl -n <namespace> create secret docker-registry ghcr-registry \
      --docker-server=ghcr.io --docker-username=<user> --docker-password=<token with read:packages>
    helm upgrade --install ... --set "imagePullSecrets[0].name=ghcr-registry"
    ```

- **linux/amd64 only:** there are no arm64 builds.
- **The chart is public:** `oci://ghcr.io/cznewt/charts/demo-apps` (0.1.0–0.3.1)
  pulls anonymously.

## App images

Each app is standalone: it calls no other service, does one simulated piece of
work per second, and runs as the container `app`.

### Logging: `demo-logging-<runtime>`

No ports and no environment variables. They write log lines once a second,
which the cluster's pod-log collection picks up.

| Image | Source | Language and library | Base image | Output |
| :-- | :-- | :-- | :-- | :-- |
| `demo-logging-go` | `logging/popular-logging-frameworks/go` | Go, [zap](https://github.com/uber-go/zap) 1.28 (production JSON config, debug level on) | `golang:1.26-alpine`, single stage | JSON on stdout: `level`, `ts` (Unix seconds), `logger` (`app`, `database`, `api`), `caller`, `msg` and the call's fields; error lines add `stacktrace` |
| `demo-logging-python` | `logging/popular-logging-frameworks/python` | Python 3.12, stdlib `logging` | `python:3.12-slim` | Plain text on **stderr**: `<date> <time>,<ms> - app.py:<line> - WARNING - Warning message, counter: 7`, cycling DEBUG → CRITICAL |
| `demo-logging-rust` | `logging/popular-logging-frameworks/rust` | Rust, `tracing` 0.1 + `tracing-subscriber` 0.3 (JSON) | built on `rust:1-alpine`, runs on `alpine:3.21` | JSON on stdout: `timestamp`, `level`, `target` (`app`, `database`, `api`), `message` and the event's fields, flattened |

The Go and Rust apps run the same loop of twelve messages:

- plain info lines;
- errors, some with context fields;
- structured fields and a nested object;
- a `database` slow-query warning;
- an `api` request line (`method`, `path`, `status`);
- a debug line from a child logger or span carrying a request id.

### Metrics: `demo-metrics-prom-<runtime>`

All three serve the Prometheus text format on `0.0.0.0:9100/metrics`. The chart
gives the pod the `k8s.grafana.com/scrape` annotations and a Service.

!!! warning "The port is fixed in the code"
    `runtimes.<rt>.metricsProm.port` only moves the chart's `containerPort`,
    Service port and scrape annotation, while the app keeps listening on 9100.
    Leave it at 9100.

| Image | Source | Language and library | Base image | Series |
| :-- | :-- | :-- | :-- | :-- |
| `demo-metrics-prom-python` | `metrics/prometheus-client/python` | Python 3.11, `prometheus-client` 0.21.0 | `python:3.11-slim` | `checkout_transactions_total{status, payment_method}`, `checkout_payment_duration_seconds{status, payment_method}` (histogram, 50 ms–5 s buckets), `checkout_active_carts`, `checkout_queue_depth`; plus the client's `process_*` and `python_*` |
| `demo-metrics-prom-go` | `metrics/prometheus-client/go` | Go, `prometheus/client_golang` (newest at build time) | `golang:1.25-alpine`, single stage | `inventory_updates_total{warehouse, operation}`, `inventory_reservation_duration_seconds` (histogram, default buckets), `inventory_stock_level`, `inventory_pending_shipments`; plus `go_*`, `process_*` and `promhttp_*` |
| `demo-metrics-prom-rust` | `metrics/prometheus-client/rust` | Rust, `prometheus` 0.13 + `tiny_http` 0.12 | built on `rust:1-alpine`, runs on `alpine:3.21` | The same four `inventory_*` series as Go; any other path answers 404 |

- **Errors:** about 8 % of ticks are errors. Python counts them as
  `status="declined"` with 0.8–2.5 s payments. Go and Rust count them as
  `operation="reserve_failed"` with 200–500 ms reservations.
- **Label values:**
    - `payment_method`: `card`, `paypal`, `apple_pay`, `bank_transfer`;
    - `warehouse`: `eu-west`, `us-east`, `ap-south`.
- **Log line:** the Python app also prints one `tick:` line per second to
  stdout.

### Traces: `demo-traces-<runtime>`

All three send one trace per second over OTLP **gRPC**. They use the
OpenTelemetry SDK and take their settings only from the standard environment
variables, which the chart sets:

| Variable | Set from |
| :-- | :-- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `otlp.endpoint` (default: the k8s-monitoring Alloy receiver on `:4317`) |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `otlp.protocol` (`grpc`) |
| `OTEL_SERVICE_NAME` | `runtimes.<rt>.traceServiceName`: `warehouse` (Go), `checkout` (Python), `payments` (Rust) |
| `OTEL_RESOURCE_ATTRIBUTES` | `service.namespace=<serviceNamespace>,deployment.environment=<environment>,language=<rt>` |

!!! note "gRPC only, plaintext"
    The apps are built with gRPC exporters, so `OTEL_EXPORTER_OTLP_PROTOCOL`
    can't switch them to OTLP/HTTP: point `otlp.endpoint` at a gRPC receiver.
    The receiver must also accept plaintext, because the Go app dials without
    TLS whatever the endpoint says.

| Image | Source | Language and library | Base image | Trace |
| :-- | :-- | :-- | :-- | :-- |
| `demo-traces-go` | `traces/opentelemetry-sdk/go` | Go, OpenTelemetry Go SDK + `otlptracegrpc` (newest at build time) | `golang:1.25-alpine`, single stage | Tracer `store/inventory`. `reserve_stock` (`sku`, `warehouse`, `quantity`) has two children: `check_warehouse` (event `reorder_triggered`), then `decrement_stock`. In about 15 % of traces, `decrement_stock` records an `out_of_stock` error with status ERROR |
| `demo-traces-python` | `traces/opentelemetry-sdk/python` | Python 3.11, `opentelemetry-sdk` 1.27.0 + the OTLP gRPC exporter | `python:3.11-slim` | Tracer `checkout.simulator`. `process_checkout` (`cart.id`, `payment.method`, `amount.usd`, `checkout.outcome`) → `validate_payment` (event `fraud_check` with `risk.score`) → `charge_card`. In about 15 % of traces, `charge_card` records a `DeclinedCardError` with status ERROR and the outcome is `declined` |
| `demo-traces-rust` | `traces/opentelemetry-sdk/rust` | Rust, `opentelemetry` 0.30 + `opentelemetry-otlp` (tonic) | built on `rust:1-alpine`, runs on `alpine:3.21` | Tracer `store/payments`. The same `reserve_stock` shape as Go: same attributes, same event, same `out_of_stock` errors |

Each trace stays inside one service. The cross-service traces and the
service-graph edges come from the `demo-traces-graph` generator.

## Generators

The generators have no image of their own. Each one is a stdlib Python script
from
[`charts/demo-apps/files/`](https://github.com/cznewt/monitor-tools/tree/main/charts/demo-apps/files):

- the chart ships the script in a ConfigMap (key `gen.py`), mounted at `/app`;
- the container runs `python /app/gen.py` on `generators.image`, which
  defaults to `mirror.gcr.io/library/python:3.12-slim`;
- `PYTHONUNBUFFERED=1` is set.

A script change ships with a chart release. The pod template's
`checksum/script` annotation restarts the pod when the script changes.

All three read the incident schedule from `generators.incident.*`:
`INCIDENT_EVERY_SECONDS`, `INCIDENT_DURATION_SECONDS`, `INCIDENT_ERROR_RATIO`
and `INCIDENT_LATENCY_FACTOR`. Each generator works out the scheduled window
from the wall clock (`now mod everySeconds < durationSeconds`), so all three
open it at the same moment without talking to each other. When the metrics
generator is enabled, the other two also get:

- `INCIDENT_URL`: its `/incident` endpoint;
- `INCIDENT_POLL_SECONDS`: how often to poll it.

That is how they follow incidents opened on demand
([Incidents](demo-apps.md#incidents)).

### `demo-metrics-generator`: `gen-metrics.py`

- **Listens** on `PORT` (9100):
    - `GET /metrics`;
    - `GET`, `POST` and `DELETE /incident`, the release's incident switch.
- **Simulates** `RATE_PER_SECOND` (5) requests a second over six routes: `GET /`,
  `/products`, `/products/{id}`, `/health`, and `POST /cart`, `/cart/checkout`.
- **Status mix:**
    - 5xx (500, 502, 503, 504) at the error ratio;
    - 4xx (400, 401, 404, 409) for another 4 %;
    - otherwise 200, or 201 for a POST.
- **Series:**
    - `http_server_request_duration_seconds{http_request_method, http_route, http_response_status_code}`,
      a histogram on the OTel default boundaries (5 ms–10 s);
    - `http_server_active_requests{http_request_method}`;
    - `demo_incident_active` and `demo_incident_seconds_remaining`.
- **Environment:** `PORT`, `RATE_PER_SECOND`, `ERROR_RATIO`, plus the
  incident variables.

### `demo-logs-generator`: `gen-logs.py`

- **Writes** one JSON line per simulated request to stdout, `RATE_PER_SECOND`
  (2) a second on average. The fields are:
    - `ts`, `service`, `service_namespace` and `environment`;
    - `level`: `info`, `warn` for a 4xx, `error` for a 5xx;
    - `method`, `route`, `status` and `latency_ms`;
    - `trace_id`, `incident` and `msg`.
- **Routes and status mix:** the same as the metrics generator.
- **`trace_id` is random:** it does not point at a stored trace, so a
  log-to-trace link from these lines finds nothing.
- **Environment:** `SERVICE_NAME`, `SERVICE_NAMESPACE`,
  `DEPLOYMENT_ENVIRONMENT`, `RATE_PER_SECOND`, `ERROR_RATIO`, plus the
  incident variables.

### `demo-traces-graph`: `gen-traces-graph.py`

- **Posts** one trace every `INTERVAL_SECONDS` (2) as OTLP/HTTP JSON to
  `OTLP_HTTP_ENDPOINT`, with the header `X-Scope-OrgID: <TENANT>`.
- **Shape:** client/server span pairs, which Tempo's service-graph processor
  turns into edges:

    ```
    storefront  SERVER  GET /cart/checkout
      storefront  CLIENT  POST /checkout   peer.service=checkout
        checkout  SERVER  POST /checkout
          checkout  CLIENT  POST /charge   peer.service=payments
            payments  SERVER  POST /charge
    ```

- **Resource attributes:** `service.name`, `service.namespace`,
  `deployment.environment` and `telemetry.sdk.language=python`. The scope is
  `demo.service-graph`.
- **Errors:** `ERROR_RATIO` (8 %) of traces fail. Every span in the trace gets
  status ERROR, and the HTTP status is 500 on the storefront and checkout
  spans and 402 on the charge spans.
- **Send failures** are counted and logged, and the loop keeps going, for
  example through a Tempo restart.
- **Environment:** `OTLP_HTTP_ENDPOINT`, `TENANT`, `INTERVAL_SECONDS`,
  `ERROR_RATIO`, `SERVICE_NAMESPACE`, `DEPLOYMENT_ENVIRONMENT`, plus the
  incident variables.

## Build and push a new tag

Nothing builds these images automatically. No workflow under
`.github/workflows` and no `just` recipe pushes them. The `instrumentation-*`
recipes run the local compose stacks under their own image names, with more
languages than the chart uses.

Build and push by hand from the repository root, logged in to ghcr
(`docker login ghcr.io`) with a token that can write packages:

```sh
TAG=2026.10-r1   # the next YYYY.MM-rN tag
for rt in go python rust; do
  docker build --platform linux/amd64 -t ghcr.io/cznewt/demo-logging-$rt:$TAG      extra/app-instrumentation/logging/popular-logging-frameworks/$rt
  docker build --platform linux/amd64 -t ghcr.io/cznewt/demo-metrics-prom-$rt:$TAG extra/app-instrumentation/metrics/prometheus-client/$rt
  docker build --platform linux/amd64 -t ghcr.io/cznewt/demo-traces-$rt:$TAG       extra/app-instrumentation/traces/opentelemetry-sdk/$rt
done
for rt in go python rust; do
  for signal in logging metrics-prom traces; do
    docker push ghcr.io/cznewt/demo-$signal-$rt:$TAG
  done
done
```

Then either install with `--set imageTag=$TAG`, or release the chart with the
new tag as its `imageTag` default and `appVersion`.

- **A new package is private:** ghcr refuses anonymous pulls of it until its
  visibility is changed in the package settings on GitHub.
- **Builds are not reproducible:**
    - the Go metrics and traces Dockerfiles run `go mod tidy`, which pulls the
      newest `client_golang` and OpenTelemetry modules at build time; only the
      Go logging app has a `go.sum`;
    - the Rust apps have no `Cargo.lock`, so each build resolves the newest
      crates `Cargo.toml` allows;
    - the Python apps pin theirs in `requirements.txt`.

## Run them without a cluster

Each source directory belongs to a self-contained compose stack, which runs the
apps next to Alloy and a local backend. From the repository root:
`just instrumentation-logging`, `just instrumentation-metrics-prom` or
`just instrumentation-traces`. See the
[app-instrumentation README](https://github.com/cznewt/monitor-tools/blob/main/extra/app-instrumentation/README.md).
