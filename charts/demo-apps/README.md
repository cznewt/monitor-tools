# demo-apps

Instrumented demo services for monitoring labs. Per runtime (Go, Python, Rust)
three apps, each switchable, plus activity generators:

| Workload | What it does |
| :-- | :-- |
| `demo-logging-<runtime>` | writes log lines with the runtime's popular logging framework (Rust/Go JSON, Python plain text) |
| `demo-metrics-prom-<runtime>` | serves Prometheus-client metrics on `:9100` (scraped through `k8s.grafana.com/*` pod annotations) |
| `demo-traces-<runtime>` | sends OTLP traces through the SDK (`OTEL_*` env): services warehouse (go), checkout (python), payments (rust) |
| `demo-traces-graph` | generator: a three-service checkout trace per tick (storefront → checkout → payments) as OTLP/HTTP JSON with an `X-Scope-OrgID` header - the client/server span pairs Tempo's service-graph processor turns into edges |
| `demo-logs-generator` | generator: JSON access-log lines of a simulated storefront (level, method, route, status, latency_ms, trace_id) |
| `demo-metrics-generator` | generator: `http_server_request_duration_seconds` / `http_server_active_requests` under the OTel semantic-convention names (the observ-viz HTTP server and RED boards read them) |

The demo apps generate their own activity (one simulated request per second).
The generators are stdlib Python scripts (`files/`) on a plain Python image;
the logs and metrics generators open an **incident window** every
`generators.incident.everySeconds` (error ratio and latency jump), so alert
exercises have something to fire on.

Image sources: `monitor-tools/extra/app-instrumentation/{logging,metrics,traces}/*/<runtime>`;
default image `<imageRegistry>/demo-<signal>-<runtime>:<imageTag>`
(signal `logging` | `metrics-prom` | `traces`).

## Install

One release per environment (namespace) - object names are fixed:

```sh
helm upgrade --install demo oci://ghcr.io/cznewt/charts/demo-apps --version 0.1.0 \
  --namespace demo-dev \
  --set environment=dev \
  --set generators.tracesGraph.tenant=dev
```

Only one runtime, or only some signals:

```yaml
runtimes:
  python: { enabled: false }
  rust: { enabled: false }
  go:
    logging: { enabled: false }
generators:
  logs: { enabled: false }
```

## Values

| Key | Default | Description |
| :-- | :-- | :-- |
| `imageRegistry` / `imageTag` | `ghcr.io/cznewt` / `2026.09-r1` | demo app image = `<registry>/demo-<signal>-<runtime>:<tag>` |
| `imagePullSecrets` | `[]` | e.g. `[{name: ghcr-registry}]` for private images |
| `environment` | `workshop` | `deployment.environment` of the traces apps and generators |
| `serviceNamespace` | `onlinestore` | `service.namespace` of the traces apps and generators |
| `otlp.endpoint` / `otlp.protocol` | Alloy receiver `:4317` / `grpc` | where the traces apps send OTLP |
| `runtimes.<go\|python\|rust>.enabled` | `true` | the runtime's three apps |
| `runtimes.<rt>.<logging\|metricsProm\|traces>.enabled` | `true` | one app |
| `runtimes.<rt>.<signal>.image` | `""` | image override |
| `runtimes.<rt>.traceServiceName` | warehouse / checkout / payments | `OTEL_SERVICE_NAME` |
| `resources.<logging\|metricsProm\|traces>` | 10m/32-48Mi → 200m/128-192Mi | per signal |
| `nodeSelector` / `tolerations` | `{}` / `[]` | every workload |
| `generators.image` | `mirror.gcr.io/library/python:3.12-slim` | the generators' runtime |
| `generators.incident.*` | every 1800 s for 300 s, errors 50 %, latency x5 | incident window (`everySeconds: 0` = off) |
| `generators.tracesGraph.*` | enabled, Alloy receiver `:4318/v1/traces`, tenant `anonymous`, every 2 s, 8 % errors | the service-graph trace generator |
| `generators.logs.*` | enabled, `storefront`, 2 lines/s, 5 % errors | the access-log generator |
| `generators.metrics.*` | enabled, `:9100`, 5 req/s, 5 % errors | the HTTP-metrics generator |

## Adopting existing objects

A release can take over plain-manifest objects of the same names (the
monitoring lab's `demo-apps.yaml` / `demo-envs.yaml`): selectors and pod labels
match. Mark them for Helm first, then install:

```sh
for o in $(kubectl -n <ns> get deploy,svc,cm -l app.kubernetes.io/part-of=demo-apps -o name); do
  kubectl -n <ns> label "$o" app.kubernetes.io/managed-by=Helm --overwrite
  kubectl -n <ns> annotate "$o" meta.helm.sh/release-name=<release> meta.helm.sh/release-namespace=<ns> --overwrite
done
```
