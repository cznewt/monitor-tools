# Demo apps

`demo-apps` is a Helm chart with an instrumented online store for monitoring
labs, courses and pipeline smoke tests. It emits every signal the
monitor-tools stack handles: logs, Prometheus metrics, OTLP traces, and a
service graph. It can open incident windows so that alerts have something to
fire on.

- Chart: `oci://ghcr.io/cznewt/charts/demo-apps`, published anonymously
  pullable from [`charts/demo-apps`](https://github.com/cznewt/monitor-tools/tree/main/charts/demo-apps)
  by the *Publish Helm charts* workflow on every push under `charts/`.
- Values reference and version history: the chart's
  [README](https://github.com/cznewt/monitor-tools/blob/main/charts/demo-apps/README.md).
  This page is the usage guide.
- Current version: **0.3.1**. Skip 0.3.0: upgrading a 0.2.0 release to it
  fails, see [Upgrading](#upgrading).

## What runs

One release per namespace, with fixed object names. Every enabled runtime (Go,
Python, Rust) runs up to three apps, and three generators run next to them:

| Workload | Signal | Where it goes | What to look for |
| :-- | :-- | :-- | :-- |
| `demo-logging-<rt>` | logs on stdout (Go / Rust JSON, Python text) | pod logs → Loki | the runtime's logging framework |
| `demo-metrics-prom-<rt>` | Prometheus client on `:9100` | scraped via `k8s.grafana.com/*` pod annotations → Mimir | Python `checkout_*` (transactions, payment duration, carts, queue); Go / Rust `inventory_*` (reservations, stock, shipments) |
| `demo-traces-<rt>` | OTLP traces (SDK) | `otlp.endpoint` (the Alloy receiver) → Tempo | `service.name` `warehouse` (Go), `checkout` (Python), `payments` (Rust) |
| `demo-metrics-generator` | OTel HTTP server metrics on `:9100` | scraped via annotations → Mimir | `http_server_request_duration_seconds`, `http_server_active_requests`, `demo_incident_*`; the release's **incident switch** |
| `demo-logs-generator` | JSON access-log lines on stdout | pod logs → Loki | `level`, `method`, `route`, `status`, `latency_ms`, `trace_id`, `incident` |
| `demo-traces-graph` | OTLP/HTTP JSON (`X-Scope-OrgID`) | `generators.tracesGraph.endpoint` → Tempo | client / server span pairs `storefront → checkout → payments`, the service graph edges |

The chart expects the cluster's collector to do three things:

- scrape pods annotated `k8s.grafana.com/scrape: "true"`: the k8s-monitoring
  chart's annotation autodiscovery, which labels them
  `job="annotation_autodiscovery..."`;
- collect pod logs;
- receive OTLP for the traces apps.

The graph generator posts straight to Tempo or to a receiver that forwards the
tenant header. App images default to
`ghcr.io/cznewt/demo-<logging|metrics-prom|traces>-<rt>:<imageTag>`. Their
sources live in [`extra/app-instrumentation`](https://github.com/cznewt/monitor-tools/tree/main/extra/app-instrumentation).
If the packages are private to you, add `imagePullSecrets`. The generators are
stdlib Python scripts on `python:3.12-slim` and need no image of their own.

## Install

### One environment per namespace

```sh
helm upgrade --install demo oci://ghcr.io/cznewt/charts/demo-apps --version 0.3.1 \
  --namespace demo-dev --create-namespace \
  --set environment=dev \
  --set generators.tracesGraph.tenant=dev
```

`environment` becomes `deployment.environment` on the traces and in the
generators' output. `generators.tracesGraph.tenant` is the Tempo tenant of the
graph traces, so point it at the tenant the rest of the environment's
telemetry lands in.

### Choose runtimes and signals

```sh
# Python only, metrics and traces apps, generators on
--set "enabledRuntimes={python}" --set "enabledSignals={metricsProm,traces}"

# every app, no generators
--set generators.enabled=false

# generators only
--set runtimes.go.enabled=false --set runtimes.python.enabled=false --set runtimes.rust.enabled=false
```

When `enabledRuntimes` and `enabledSignals` are non-empty, they replace the
per-runtime and per-signal `enabled` flags. Each generator also has its own
flag: `generators.<tracesGraph|logs|metrics>.enabled`.

### One app under its own name

A course lab gives every student their own app in their namespace:

```sh
helm upgrade --install lab-app oci://ghcr.io/cznewt/charts/demo-apps --version 0.3.1 \
  --namespace "$LAB_NAMESPACE" \
  --set partOf=lab-app \
  --set "enabledRuntimes={$LAB_LANG}" --set "enabledSignals={metricsProm}" \
  --set "runtimes.$LAB_LANG.metricsProm.name=metrics-app" \
  --set generators.enabled=false
```

## Incidents

An incident window raises the error ratio and the latency together. The
metrics and logs generators serve more 5xx responses and slower requests; the
graph traces fail more often, with every span stretched. RED, error-ratio and
latency alerts then have something to fire on.

**On a schedule:** by default a window of `generators.incident.durationSeconds`
(300 s) opens every `everySeconds` (1800 s), with `errorRatio` 0.5 and
`latencyFactor` 5. Set `everySeconds: 0` to switch the schedule off.

**On demand (0.3.0+):** the metrics generator is the incident switch. Its image
has Python but no curl:

```sh
# open a 5-minute window now (optional: &errorRatio=0.5&latencyFactor=5)
kubectl -n demo-dev exec deploy/demo-metrics-generator -- python -c \
  "import urllib.request as u; print(u.urlopen(u.Request('http://localhost:9100/incident?seconds=300', method='POST')).read().decode())"

# or through a port-forward
kubectl -n demo-dev port-forward svc/demo-metrics-generator 9100 &
curl -X POST 'http://localhost:9100/incident?seconds=300&errorRatio=0.6'
curl http://localhost:9100/incident             # the window in force
curl -X DELETE http://localhost:9100/incident   # end it now
```

- Every call answers with the window as JSON: `active`, `until`,
  `seconds_remaining`, `source` (`manual` or `schedule`), `errorRatio`,
  `latencyFactor`.
- Out-of-range parameters get a 400. The bounds are `seconds` 1-86400,
  `errorRatio` 0-1, `latencyFactor` 1-100.
- An on-demand window wins over the schedule. `DELETE` ends whichever window
  is open, a scheduled one for the rest of its slot.
- The logs and traces generators poll the switch every
  `generators.incident.pollSeconds` (5 s) and follow it. If the switch is
  unreachable, they fall back to the schedule.

During a window:

| Where | What changes |
| :-- | :-- |
| Mimir | the `http_server_request_duration_seconds` 5xx share and latency; `http_server_active_requests` up to 12; `demo_incident_active` = 1 and `demo_incident_seconds_remaining` counting down |
| Loki | lines with `"incident": true`, mostly `level: error` with 5xx `status`, and higher `latency_ms` |
| Tempo | the graph traces fail at the window's error ratio (span status ERROR, HTTP 500 / 402), spans are longer, and the storefront server span carries `demo.incident = true` |

With the default 60 s scrape interval, give the metrics a couple of scrapes
before you query `rate()`. `demo_incident_active` is the quickest check that
the window registered. It also works as an annotation query for boards.

## See it in Grafana

Boards (observ-viz, rendered by monitor-tools):

- `demos.demoApp`, *Online store (demo app)*, in *Workloads / Demos*. It shows
  the storefront RED metrics (with the error ratio against its own 1 h
  median), plus Checkout (Python) and Inventory (Go, Rust) tabs. Its rules
  record `namespace:demo_*` and alert on:
  - `DemoAppErrorRatioHigh` and `DemoAppLatencyHigh`;
  - `DemoAppErrorRatioAnomalous`;
  - `DemoCheckoutDeclineRatioHigh` and `DemoInventoryReservationFailuresHigh`;
  - `DemoAppDown`.

  One incident fires the storefront alerts within minutes.
- The HTTP server and RED boards read the metrics generator's OTel names.

Explore queries (namespace `demo-dev`, tenant `dev` in the monitoring lab):

```promql
# storefront error ratio
sum by (namespace) (rate(http_server_request_duration_seconds_count{namespace="demo-dev", http_response_status_code=~"5.."}[5m]))
/ sum by (namespace) (rate(http_server_request_duration_seconds_count{namespace="demo-dev"}[5m]))

# is an incident open?
demo_incident_active{namespace="demo-dev"}
```

```logql
# access lines written during an incident, by status
sum by (status) (count_over_time({namespace="demo-dev", service_name="demo-logs-generator"} | json | incident="true" [5m]))
```

```traceql
{ resource.service.name = "storefront" && span.demo.incident = true }
```

## The monitoring lab

`monitor-lab-model` runs three releases named `demo-apps`:

| Environment | Namespace | Graph-trace tenant |
| :-- | :-- | :-- |
| workshop | `global-monitor-demo` | `anonymous` |
| dev | `demo-dev` | `dev` |
| prod | `demo-prod` | `prod` |

Values and the install script live in
`manifests/monitor-lab/demo-apps/`: `values.yaml` holds the shared settings
(pull secret, node, Tempo endpoint), and `workshop.yaml`, `dev.yaml` and
`prod.yaml` add each environment's settings.

```sh
cd monitor-lab-model/manifests/monitor-lab/demo-apps
./apply.sh                      # all three environments
./apply.sh dev                  # one
DEMO_APPS_VERSION=0.3.1 HELM_EXTRA=--dry-run=server ./apply.sh dev
```

`apply.sh` runs `helm upgrade --install --take-ownership --force-conflicts
--wait`:

- `--take-ownership` adopts objects applied before Helm (the lab's former
  plain manifests), in place.
- `--force-conflicts` lets server-side apply take over the fields `kubectl
  apply` owned.

## Upgrading

- Pin `--version`, and read the chart README's *Changes* before you upgrade.
- **0.2.0 → 0.3.x: use 0.3.1.** 0.3.0 switched the generators to
  `strategy: Recreate`, but server-side apply cannot make that switch on an
  existing Deployment: the API rejects it with `spec.strategy.rollingUpdate:
  Forbidden`. A server-side dry run did not catch this. 0.3.1 keeps
  `RollingUpdate` with `maxSurge: 0` / `maxUnavailable: 1`, which is Recreate
  in effect for one replica, so no surge pod can stall a rollout under a tight
  namespace quota.
- A failed upgrade leaves the old pods running. Re-run `helm upgrade` with a
  fixed version: Helm upgrades from a failed revision.
