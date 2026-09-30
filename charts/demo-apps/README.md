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
| `demo-metrics-generator` | generator: `http_server_request_duration_seconds` / `http_server_active_requests` under the OTel semantic-convention names (the observ-viz HTTP server and RED boards read them); also the release's incident switch (below) |

The demo apps generate their own activity (one simulated request per second).
The generators are stdlib Python scripts (`files/`) on a plain Python image;
the generators open an **incident window** every
`generators.incident.everySeconds` (error ratio and latency jump), so alert
exercises have something to fire on.

### Incidents on demand (0.3.0)

The metrics generator is the release's incident switch. Open a window now,
whatever the schedule says:

```sh
# from a pod in the namespace (or kubectl port-forward svc/demo-metrics-generator 9100)
curl -X POST 'http://demo-metrics-generator:9100/incident?seconds=300'   # optional &errorRatio=0.5&latencyFactor=5
curl http://demo-metrics-generator:9100/incident                        # the window in force
curl -X DELETE http://demo-metrics-generator:9100/incident              # end it now
```

Each answers the window as JSON - `{"active", "until", "seconds_remaining",
"source": "manual"|"schedule", "errorRatio", "latencyFactor"}`; out-of-range
parameters get a 400 (`seconds` 1-86400, `errorRatio` 0-1, `latencyFactor`
1-100). An on-demand window wins over the schedule; `DELETE` ends whichever is
open, a scheduled one for the rest of its window. `everySeconds: 0` turns only
the schedule off - the switch keeps working.

The logs and traces generators poll the switch every
`generators.incident.pollSeconds` and follow it: log lines carry
`"incident": true` and the window's error ratio and latency, traces fail at the
window's error ratio with every span stretched by its latency factor (the
storefront server span carries `demo.incident=true`). While the switch cannot
be reached they fall back to the schedule. The metrics generator exports the
state as `demo_incident_active` and `demo_incident_seconds_remaining`.

Generators roll out without a surge pod (`maxSurge: 0`, `maxUnavailable: 1` -
Recreate in effect for their one replica), so a tight namespace quota cannot
stall an upgrade.

Image sources: `monitor-tools/extra/app-instrumentation/{logging,metrics,traces}/*/<runtime>`;
default image `<imageRegistry>/demo-<signal>-<runtime>:<imageTag>`
(signal `logging` | `metrics-prom` | `traces`).

## Install

One release per environment (namespace) - object names are fixed:

```sh
helm upgrade --install demo oci://ghcr.io/cznewt/charts/demo-apps --version 0.3.1 \
  --namespace demo-dev \
  --set environment=dev \
  --set generators.tracesGraph.tenant=dev
```

One app - e.g. a student's own metrics app in their namespace, under its own
name (0.2.0):

```sh
helm upgrade --install lab-app oci://ghcr.io/cznewt/charts/demo-apps --version 0.3.1 \
  --namespace "$LAB_NAMESPACE" \
  --set partOf=lab-app \
  --set "enabledRuntimes={$LAB_LANG}" --set "enabledSignals={metricsProm}" \
  --set "runtimes.$LAB_LANG.metricsProm.name=metrics-app" \
  --set generators.enabled=false
```

Or switch runtimes / signals off one by one (0.1.0 and later):

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
| `enabledRuntimes` | `[]` | when non-empty, only these runtimes render (replaces `runtimes.<rt>.enabled`; 0.2.0) |
| `enabledSignals` | `[]` | when non-empty, only these signals render - `logging`, `metricsProm` (or `metrics-prom`), `traces` (replaces the per-signal `enabled`; 0.2.0) |
| `runtimes.<go\|python\|rust>.enabled` | `true` | the runtime's three apps |
| `runtimes.<rt>.<logging\|metricsProm\|traces>.enabled` | `true` | one app |
| `runtimes.<rt>.<signal>.image` | `""` | image override |
| `runtimes.<rt>.<signal>.name` | `demo-<signal>-<rt>` | object name override (Deployment, Service, `app.kubernetes.io/name`; 0.2.0) |
| `runtimes.<rt>.traceServiceName` | warehouse / checkout / payments | `OTEL_SERVICE_NAME` |
| `resources.<logging\|metricsProm\|traces>` | 10m/32-48Mi → 200m/128-192Mi | per signal |
| `nodeSelector` / `tolerations` | `{}` / `[]` | every workload |
| `generators.enabled` | `true` | all generators at once (0.2.0) |
| `generators.image` | `mirror.gcr.io/library/python:3.12-slim` | the generators' runtime |
| `generators.incident.*` | every 1800 s for 300 s, errors 50 %, latency x5, poll every 5 s | scheduled incident window (`everySeconds: 0` = schedule off); `pollSeconds` - how often the logs / traces generators ask the switch (0.3.0) |
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

## Changes

- **0.3.1** - generators roll out with `maxSurge: 0` / `maxUnavailable: 1` instead of `strategy: Recreate`: server-side apply cannot switch an existing Deployment from RollingUpdate to Recreate (`spec.strategy.rollingUpdate: Forbidden`), so upgrading a 0.2.0 release to 0.3.0 fails - use 0.3.1.
- **0.3.0** - incidents on demand: `POST` / `GET` / `DELETE /incident` on the metrics generator, followed by the logs and traces generators (`generators.incident.pollSeconds`); `demo_incident_active` / `demo_incident_seconds_remaining`; the traces generator now has incident windows too (failed-trace share and span durations); generators roll out with `strategy: Recreate`.
- **0.2.0** - additive, renders exactly what 0.1.0 renders with default values: `enabledRuntimes` / `enabledSignals` shortcuts, `runtimes.<rt>.<signal>.name` overrides, `generators.enabled` master switch.
- **0.1.0** - first release.
