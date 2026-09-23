# Configuration Documentation

The `monitor-tools` uses YAML configuration files to define how monitoring resources are synced, rendered, and applied. These files are typically located in `/config` within the Docker container (mapped to `docker/files/config` locally).

## Global Structure

The configuration file generally contains the following top-level keys:

- `name`: The environment name (e.g., `default`).
- `prometheus`: Settings for Prometheus resource rendering (e.g., `render: mimirtool`).
- `grafana`: Settings for Grafana resource rendering: `render: grizzly` (classic dashboards via grr), `render: plain` (JSON files) or `render: grafanactl` (app-platform resources, needed for schema v2 dashboards).
- `loki` (Optional): renders the Loki rule groups a mixin lists in `lokiRuleGroups`. `render: lokitool` loads them through the ruler API (needs a writable ruler store); `render: configmap` wraps them in a ConfigMap (`namespace`, `labels`) that a Loki config sidecar syncs into the ruler's rule directory, which is how a Loki on the read-only local rule store gets them.
- `mixins`: A map of mixin definitions.
- `libs` (Optional): A map of observ-lib (or any reusable Jsonnet library) definitions vendored alongside mixins.
- `dashboards` (Optional): A map of static Grafana dashboard releases (from grafana.com or any HTTP URL).
- `pyrra` (Optional): Configuration for Pyrra SLOs.
- `sloth` (Optional): Configuration for Sloth SLOs.

## Prometheus Rendering

The `prometheus:` block selects how a config's mixin rule groups (recording + alerting) are rendered. Set `render` to one of:

- `mimirtool`: render Mimir/Cortex rule-group files (and plain Prometheus rule files), applied to a Mimir / Grafana Cloud ruler with `mimirtool`.
- `plain`: render plain Prometheus rule-group files only.
- `configmap`: wrap each mixin's rule groups in a Kubernetes ConfigMap, ready to `kubectl apply`. A config-reloader sidecar (e.g. [kiwigrid/k8s-sidecar](https://github.com/kiwigrid/k8s-sidecar)) that watches the configured labels mounts the rules into Prometheus via `rule_files`.

### `render: configmap`

```yaml
prometheus:
  render: configmap
  namespace: monitoring        # namespace stamped on every ConfigMap (default: default)
  labels:                      # labels the sidecar selects ConfigMaps on
    prometheus_rule: "1"
```

One ConfigMap is rendered per mixin (named after the mixin) into `/build/<env>/configmap/prom-rules/`. Its recording and alerting groups are stored under `data` as a single `{ groups: [...] }` Prometheus rule file:

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

- **namespace** (optional): namespace set on every rendered ConfigMap. Defaults to `default`.
- **labels** (optional): map of labels added to each ConfigMap's `metadata.labels`. These are what your sidecar (or operator) selects on; quote numeric-looking values (`"1"`) so they stay strings.

Applying the ConfigMaps is left to your deployment flow (`kubectl apply`, Argo CD, Flux, …) — the image does not ship `kubectl`. `lint-resources` validates the embedded rules with `promtool`. See [Examples](examples.md) for the full sidecar wiring.

## Mixin Configuration

Mixins are the core building blocks. Each mixin entry under `mixins` defines where to get the mixin and how to configure it.

### Example: Git Source (`example-mixins.yaml`)

```yaml
mixins:
  node:
    source:
      git:
        url: https://github.com/prometheus/node_exporter.git
        ref: master
        depth: 1
      includePaths:
        - docs/node-mixin/**/*
      newRootPath: docs/node-mixin
    config:
      mimirNamespace: node
      grafanaDashboardFolder: Platform
```

### Example: Local Directory Source (`default.yaml`)

```yaml
mixins:
  base:
    source:
      directory:
        path: /mixins/base-mixin
    config:
      mimirNamespace: base
      grafanaDashboardFolder: Base
```

### Fields

- **source**: Defines the origin of the mixin (`git` or `directory`).
    - **git**: Fetches from a remote repository.
    - **directory**: Uses a local path.
- **config**: Parameters passed to the mixin's Jsonnet code. Common parameters include:
    - `mimirNamespace`: The namespace for Mimir rules.
    - `grafanaDashboardFolder`: The folder title in Grafana.
    - `grafanaDashboardFolderUid`: The folder's uid. Defaults to the slug of the title (`Upstream / CI/CD` -> `ci-cd`); set it when two folders share a title.
    - `grafanaDashboardFolderParent`: Title of a parent folder. The renderer emits the parent too and nests the folder under it, so a tree like `Upstream / kubernetes-mixin` comes out of the config. `grafanaDashboardFolderParentUid` overrides the parent's uid the same way.

```yaml
mixins:
  kubernetes:
    config:
      grafanaDashboardFolder: kubernetes-mixin
      grafanaDashboardFolderParent: Upstream
```

Nesting needs `grafana.render: grafanactl`; the grizzly path creates flat folders only.

A mixin that emits whole Dashboard resources (observ-viz does) can instead file
each board itself: the renderer reads the board's `grafana.app/folder`
annotation, and `observ-viz.dev/folder-path` when the board sits deeper than one
level, and emits every folder in that chain.

## Library (observ-lib) Configuration

The `libs` section vendors reusable Jsonnet libraries (the `*-observ-lib` modules from [grafana/jsonnet-libs](https://github.com/grafana/jsonnet-libs), shared helpers, etc.) alongside mixins. Libraries don't render to anything on their own — they're build-time dependencies that mixins `import`.

### Example (`example-observ-lib.yaml`)

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

### Fields

- **source**: Same `git` / `directory` schema as a mixin's source. Use `includePaths` and `newRootPath` to narrow a multi-lib monorepo (like grafana/jsonnet-libs) down to the single subdirectory you want.
- **No `config:` block**: libraries are pure Jsonnet — they're consumed by mixins, not rendered into Grafana/Prometheus resources directly.

See [docs/mixins.md](mixins.md) for the catalog of common observ-libs.

## Static Dashboard Configuration

The `dashboards` section pulls released Grafana dashboards as raw JSON and turns them into Grizzly resources. Each entry must be pinned (revision number for `grafana`, optional `sha256` for `http`) so that builds are reproducible. To release a new version of a dashboard, bump the pin and resync.

### Source: `grafana`

Fetches a published revision from the Grafana.com community dashboards catalog (`https://grafana.com/grafana/dashboards/<id>`).

```yaml
dashboards:
  node-exporter-full:
    source:
      grafana:
        id: 1860
        revision: 41          # required — acts as the release pin
    config:
      grafanaDashboardFolder: Platform
      uid: node-exporter-full
      datasources:
        DS_PROMETHEUS: prometheus
```

### Source: `http`

Fetches dashboard JSON from any HTTP(S) URL. Use this for self-hosted exports or vendor-published JSON outside grafana.com.

```yaml
dashboards:
  cadvisor:
    source:
      http:
        url: https://raw.githubusercontent.com/google/cadvisor/master/deploy/grafana/cadvisor.json
        sha256: <optional hex digest>   # if set, sync fails on mismatch
    config:
      grafanaDashboardFolder: Platform
      uid: cadvisor
      datasources:
        DS_PROMETHEUS: prometheus
```

### Fields

- **source.grafana.id** / **source.grafana.revision**: Dashboard ID and revision number from grafana.com. The revision is the release identifier — never use "latest".
- **source.http.url**: Direct URL to dashboard JSON.
- **source.http.sha256** (optional): SHA-256 of the file. If provided, sync aborts on mismatch.
- **config.grafanaDashboardFolder** (optional): Target folder in Grafana. A folder resource is generated automatically.
- **config.uid** (optional): Dashboard UID. Defaults to the slugified dashboard name.
- **config.datasources** (optional): Map of `${PLACEHOLDER}` → datasource name. Most community dashboards use `${DS_PROMETHEUS}` etc.; this map substitutes them with the real datasource UIDs/names in your Grafana.

### Pipeline

1. **Sync**: `sync-dashboards` (also called by `sync-all-mixins`) downloads each pinned JSON to `/source/<env>/dashboards/<name>.json`.
2. **Render**: `render-grizzly-static-grafana-dashboards` (and the plain variant) wrap them as Grizzly `Dashboard` resources, applying the datasource substitutions.
3. **Apply**: handled by the same `apply-grizzly-grafana-dashboards` script as mixin-derived dashboards.

## Grafana Rendering: `render: grafanactl`

Renders dashboards and folders as Grafana app-platform resources and pushes them through Grafana's Kubernetes-style API (`/apis/dashboard.grafana.app/...`). Use it for schema v2 dashboards (for example the observ-viz mixin), which grizzly cannot push.

```yaml
grafana:
  render: grafanactl
```

- A dashboard whose spec has `elements` and `layout` is rendered as `dashboard.grafana.app/v2beta1`; anything else as `dashboard.grafana.app/v0alpha1`. Static `dashboards:` go the same way.
- The folder comes from `config.grafanaDashboardFolder` and rides in the `grafana.app/folder` annotation. Its uid is the slugified folder name (`CI/CD (upstream)` becomes `ci-cd-upstream`).
- The dashboard uid is the uid the mixin set when it is a valid Grafana uid (kubernetes-mixin cross-links its boards by those), otherwise the file name. A v2 spec carries no uid, so the file name is used.
- `apply-grafanactl-grafana-folders` and `apply-grafanactl-grafana-dashboards` create or update each resource with `curl`. Set `GRAFANA_URL` plus either `GRAFANA_TOKEN` or `GRAFANA_USER` and `GRAFANA_PASSWORD`. `GRAFANA_NAMESPACE` defaults to `default` (org 1).
- The target Grafana needs the feature toggles `kubernetesDashboards`, `dashboardNewLayouts` and `kubernetesClientDashboardsFolders` for v2 boards.

## Extra Jsonnet paths: `jpaths`

A mixin may list extra `-J` paths, relative to its mixin directory. Every renderer adds them after the mixin's `vendor/`. This is how a vendored repository that imports its own files by repo-relative path resolves:

```yaml
mixins:
  observ-viz-platform:
    source:
      directory:
        path: /mixins/observ-viz-mixin
    jpaths:
      - vendor/github.com/cznewt/observ-viz
    config:
      scenario: platform
      mimirNamespace: observ-viz-platform
      grafanaDashboardFolder: Platform (observ-viz)
```

`config.mimirAlertNamespace` (optional) puts a mixin's alert groups in their own Mimir namespace, next to the recording rules in `mimirNamespace`.

Rendered rule files are named `<namespace>-<group>.yaml`, so mixins that share a group name no longer overwrite each other's files.

## SLO Configuration

`pyrra: {render: mimirtool}` renders the SLOs twice: as plain Prometheus rule files, and as one-group Mimir rule files under `pyrra.namespace` (default `pyrra`), which the mimirtool apply loads into the ruler. `pyrra.genericRules: false` leaves out Pyrra's own UI series (`pyrra_objective`, `pyrra_window`, `pyrra_availability`); Mimir loads them, but `mimirtool rules check` rejects their names for carrying no colon.

Service Level Objectives can be defined using Pyrra or Sloth.

### Pyrra (`example-pyrra.yaml`)

Defines SLOs to be processed by Pyrra.

```yaml
pyrra:
  render: mimirtool
  slos:
    prometheus-api-query:
      apiVersion: pyrra.dev/v1alpha1
      kind: ServiceLevelObjective
      spec:
        target: '99.0'
        window: 7d
        # ... indicator definition
```

### Sloth (`example-sloth.yaml`)

Defines SLOs using the Sloth format.

```yaml
sloth:
  render: mimirtool
  slos:
    home-wifi:
      service: "home-wifi"
      slos:
        - name: "good-wifi-client-satisfaction"
          objective: 95
          sli:
            # ... SLI definition
```

## Available Example Files

- [default.yaml](../docker/files/config/default.yaml): Standard configuration using local mixins.
- [example-mixins.yaml](../docker/files/config/example-mixins.yaml): Demonstrates fetching mixins from Git.
- [example-observ-lib.yaml](../docker/files/config/example-observ-lib.yaml): Example using Grafana's Jsonnet libs.
- [example-pyrra.yaml](../docker/files/config/example-pyrra.yaml): Pyrra SLO examples.
- [example-sloth.yaml](../docker/files/config/example-sloth.yaml): Sloth SLO examples.
- [example-dashboards.yaml](../docker/files/config/example-dashboards.yaml): Static Grafana dashboards from grafana.com and HTTP URLs.
