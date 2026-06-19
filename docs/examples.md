# Examples

Worked examples for common `monitor-tools` flows. Each corresponds to a ready-to-run config under [`docker/files/config`](https://github.com/cznewt/monitor-tools/tree/main/docker/files/config); point `CONFIG_FILE` at one and run `do-all` (or the individual `render` / `lint` / `apply` steps).

## Prometheus rules as Kubernetes ConfigMaps

Config: [`example-prometheus-configmap.yaml`](../docker/files/config/example-prometheus-configmap.yaml)

Render a mixin's recording + alerting rules as Kubernetes ConfigMaps and let a config-reloader sidecar mount them into Prometheus — instead of pushing them to a Mimir/Cortex ruler. This is the same ConfigMap-watch pattern the Grafana and prometheus-community Helm charts use, driven here by [kiwigrid/k8s-sidecar](https://github.com/kiwigrid/k8s-sidecar).

```yaml
name: example-prometheus-configmap

prometheus:
  render: configmap
  namespace: monitoring
  labels:
    prometheus_rule: "1"

mixins:
  base:
    config:
      mimirNamespace: base
    source:
      directory:
        path: /mixins/base-mixin
```

Render it:

```bash
CONFIG_FILE=/config/example-prometheus-configmap.yaml render-resources
```

Each mixin yields one ConfigMap under `/build/example-prometheus-configmap/configmap/prom-rules/`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: base
  namespace: monitoring
  labels:
    prometheus_rule: "1"
data:
  base.yaml: |
    groups:
      - name: base
        rules:
          - alert: Watchdog
            expr: vector(1)
            labels:
              severity: info
            annotations:
              summary: This is an alert meant to ensure that the entire alerting pipeline is functional.
```

Validate the embedded rules at any time (runs `promtool check rules` over each ConfigMap's `data`):

```bash
CONFIG_FILE=/config/example-prometheus-configmap.yaml lint-resources
```

Apply with your deployment tool of choice — `monitor-tools` does not ship `kubectl`, so this step is left to you / your GitOps controller:

```bash
kubectl apply -n monitoring -f /build/example-prometheus-configmap/configmap/prom-rules/
```

Finally, wire the sidecar to the same namespace + labels so it mounts the rules into Prometheus:

```yaml
# Prometheus pod: k8s-sidecar watching prometheus_rule=1 ConfigMaps
- name: rules-sidecar
  image: kiwigrid/k8s-sidecar:latest
  env:
    - { name: LABEL,       value: "prometheus_rule" }
    - { name: LABEL_VALUE, value: "1" }
    - { name: FOLDER,      value: "/etc/prometheus/rules" }
    - { name: NAMESPACE,   value: "monitoring" }
  volumeMounts:
    - { name: rules, mountPath: /etc/prometheus/rules }
```

Prometheus then loads them via `rule_files: ["/etc/prometheus/rules/*.yaml"]`.

## Grafana library panels

Grafana has no file/sidecar provisioner for **library panels** (library elements) — unlike dashboards and datasources, they exist only in the Grafana DB and must be managed through the API. `monitor-tools` renders them as grizzly `LibraryElement` resources and pushes them with `grr`, so a panel can be authored once with grafonnet and reused across dashboards.

A mixin exposes them under `grafanaLibraryPanels`, keyed by name. Build the panel model with grafonnet and wrap it with `g.librarypanel` (add `kind`, which grafonnet omits — `1` = panel, `2` = variable):

```jsonnet
// mixin.libsonnet
local g = import 'g.libsonnet';
local lp = g.librarypanel;
local ts = g.panel.timeSeries;
local prometheus = g.query.prometheus;

{
  grafanaLibraryPanels+:: {
    'requests-per-second':
      lp.withUid('lib-requests-per-second')
      + lp.withName('Requests per second')
      + lp.withType('timeseries')
      + lp.withModel(
        ts.new('Requests per second')
        + ts.standardOptions.withUnit('reqps')
        + ts.queryOptions.withTargets([
          prometheus.new('${datasource}', 'sum(rate(http_requests_total[5m]))')
          + prometheus.withLegendFormat('rps'),
        ])
      ),
  },
}
```

Each entry may also be a bare panel object (used directly as the model, with `uid` derived from the key and `kind` defaulting to `1`). The panel's folder follows the mixin's `grafanaDashboardFolder` (rendered into `spec.folderUid`). With `grafana.render: grizzly`, `render-resources` writes one resource per panel under `/build/<env>/grizzly/grafana-library-panels/`:

```yaml
apiVersion: grizzly.grafana.com/v1alpha1
kind: LibraryElement
metadata:
  name: lib-requests-per-second   # == spec.uid
spec:
  uid: lib-requests-per-second
  name: Requests per second
  kind: 1
  type: timeseries
  folderUid: monitoring
  model:
    type: timeseries
    title: Requests per second
    # ...full grafonnet panel model...
```

`apply-resources` then applies folders → library panels → dashboards (so a dashboard embedding a library panel resolves it). Library panels are optional: a mixin without `grafanaLibraryPanels` renders nothing and is skipped.

## More configs

| Config | Demonstrates |
| --- | --- |
| [`default.yaml`](../docker/files/config/default.yaml) | Local + Git mixins, Mimir rules (`mimirtool`) + Grafana (`grizzly`) |
| [`example-mixins.yaml`](../docker/files/config/example-mixins.yaml) | Fetching mixins from Git |
| [`example-observ-lib.yaml`](../docker/files/config/example-observ-lib.yaml) | Vendoring observ-libs alongside mixins |
| [`example-dashboards.yaml`](../docker/files/config/example-dashboards.yaml) | Static grafana.com / HTTP dashboards |
| [`example-pyrra.yaml`](../docker/files/config/example-pyrra.yaml) | Pyrra SLOs |
| [`example-sloth.yaml`](../docker/files/config/example-sloth.yaml) | Sloth SLOs |
