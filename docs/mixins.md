# Mixins & observ-libs Documentation

The `monitor-tools` project consumes two related kinds of upstream Jsonnet content:

- **Mixins** — bundles of Prometheus alerts, recording rules, and Grafana dashboards. Each mixin is a self-contained module that renders directly into deployable resources.
- **observ-libs** — reusable Jsonnet libraries that mixins (or your own jsonnet code) `import`. They provide panel/row/dashboard helpers, common selectors, alert templates, etc. Libraries don't render to anything on their own; they're build-time dependencies.

Both are vendored via `vendir` and rendered with `jsonnet`. Mixins live under `mixins:` in the config; libraries live under `libs:`.

## Mixin Configuration

Mixins are defined in the `mixins` section of your configuration file (e.g., `default.yaml`).

```yaml
mixins:
  node:
    source:
      git:
        url: https://github.com/prometheus/node_exporter.git
        ref: master
    config:
      mimirNamespace: node
      grafanaDashboardFolder: Platform
```

## Library (observ-lib) Configuration

Libraries are defined under `libs:` and use the same `vendir` source schema as mixins. They get vendored into the per-environment source tree so any mixin's jsonnet can `import 'lib-name/<file>.libsonnet'` from its `vendor/` dir.

```yaml
libs:
  windows-observ-lib:
    source:
      git:
        url: https://github.com/grafana/jsonnet-libs.git
        ref: master
        depth: 1
      includePaths:
        - windows-observ-lib/**/*
      newRootPath: windows-observ-lib
```

A library entry has no `config:` block (libraries are pure jsonnet — they're consumed by mixins, not rendered into resources directly). The mixin that depends on the lib references it via `jsonnetfile.json` and `jb install`, OR the library is checked out next to the mixin and consumed by relative path.

## Common Mixins

Here is a list of commonly used mixins available in the example configurations.

### Kubernetes

| Mixin | Source | Description |
| :--- | :--- | :--- |
| **[Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin)** | `kubernetes-monitoring/kubernetes-mixin` | Cluster-level monitoring (kubelet, cadvisor, apiserver, etc.). |
| **[Kube State Metrics](https://github.com/kubernetes/kube-state-metrics)** | `kubernetes/kube-state-metrics` | Metrics about the state of Kubernetes objects. |
| **[Ingress NGINX](https://github.com/adinhodovic/ingress-nginx-mixin)** | `adinhodovic/ingress-nginx-mixin` | Monitoring for NGINX Ingress Controller. |
| **[Cert Manager](https://github.com/imusmanmalik/cert-manager-mixin)** | `imusmanmalik/cert-manager-mixin` | Monitoring for Jetstack Cert Manager. |
| **[Argo CD](https://github.com/adinhodovic/argo-cd-mixin)** | `adinhodovic/argo-cd-mixin` | Monitoring for Argo CD. |
| **[Kubernetes Events](https://github.com/adinhodovic/kubernetes-events-mixin)** | `adinhodovic/kubernetes-events-mixin` | Alerts and dashboards for Kubernetes events. |
| **[OpenCost](https://github.com/adinhodovic/opencost-mixin)** | `adinhodovic/opencost-mixin` | Cost monitoring for Kubernetes clusters. |

### Application & Infrastructure

| Mixin | Source | Description |
| :--- | :--- | :--- |
| **[Alloy](https://github.com/grafana/alloy)** | `grafana/alloy` | Monitoring for Grafana Alloy collector. |
| **[Blackbox Exporter](https://github.com/adinhodovic/blackbox-exporter-mixin)** | `adinhodovic/blackbox-exporter-mixin` | Monitoring for Blackbox probes. |
| **[Django](https://github.com/adinhodovic/django-mixin)** | `adinhodovic/django-mixin` | Monitoring for Django applications. |

## Common observ-libs

Most of the curated `*-observ-lib` modules live in [grafana/jsonnet-libs](https://github.com/grafana/jsonnet-libs). Vendor them by pointing `source.git.url` at that repo and narrowing `includePaths` to the lib directory.

| Library | Source path | Description |
| :--- | :--- | :--- |
| **[windows-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/windows-observ-lib)** | `grafana/jsonnet-libs//windows-observ-lib` | Panels and helpers for Windows host monitoring. |
| **[golang-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/golang-observ-lib)** | `grafana/jsonnet-libs//golang-observ-lib` | Go runtime metrics dashboard helpers. |
| **[jvm-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/jvm-observ-lib)** | `grafana/jsonnet-libs//jvm-observ-lib` | JVM (heap, GC, threads) dashboards. |
| **[kafka-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/kafka-observ-lib)** | `grafana/jsonnet-libs//kafka-observ-lib` | Kafka broker / topic dashboards. |
| **[opentelemetry-collector-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/opentelemetry-collector-observ-lib)** | `grafana/jsonnet-libs//opentelemetry-collector-observ-lib` | OTel Collector pipeline dashboards. |
| **[postgres-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/postgres-observ-lib)** | `grafana/jsonnet-libs//postgres-observ-lib` | PostgreSQL dashboards. |
| **[process-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/process-observ-lib)** | `grafana/jsonnet-libs//process-observ-lib` | Per-process metrics dashboards (process_exporter). |
| **[snmp-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/snmp-observ-lib)** | `grafana/jsonnet-libs//snmp-observ-lib` | SNMP exporter dashboards. |
| **[alerts-observ-lib](https://github.com/grafana/jsonnet-libs/tree/master/alerts-observ-lib)** | `grafana/jsonnet-libs//alerts-observ-lib` | Reusable Prometheus alert templates. |

Other useful shared libraries from the same repo: `common-lib`, `logs-lib`, `mixin-utils`, `status-panels-lib`.

## Usage

To use a mixin (or library):

1.  **Add it to your config file**: Define the `source` (git URL and ref) and — for mixins — the `config` block.
2.  **Sync**: Run `sync-all-mixins` (or `do-all`) to vendor the files. This populates both `mixins/` and (when `libs:` entries exist) the lib vendor trees.
3.  **Render**: Run `render-all-resources` to generate the rules and dashboards. Libraries themselves don't produce output — they're imported by the mixins they're vendored alongside.
4.  **Apply**: Run `apply-all-resources` to push them to Grafana and Mimir.
