# Configuration Documentation

The `monitor-tools` uses YAML configuration files to define how monitoring resources are synced, rendered, and applied. These files are typically located in `/config` within the Docker container (mapped to `docker/files/config` locally).

## Global Structure

The configuration file generally contains the following top-level keys:

- `name`: The environment name (e.g., `default`).
- `prometheus`: Settings for Prometheus resource rendering (e.g., `render: mimirtool`).
- `grafana`: Settings for Grafana resource rendering (e.g., `render: grizzly`).
- `mixins`: A map of mixin definitions.
- `dashboards` (Optional): A map of static Grafana dashboard releases (from grafana.com or any HTTP URL).
- `pyrra` (Optional): Configuration for Pyrra SLOs.
- `sloth` (Optional): Configuration for Sloth SLOs.

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
    - `grafanaDashboardFolder`: The folder name in Grafana.

## Static Dashboard Configuration

The `dashboards` section pulls released Grafana dashboards as raw JSON and turns them into Grizzly resources. Each entry must be pinned (revision number for `grafanaCom`, optional `sha256` for `http`) so that builds are reproducible. To release a new version of a dashboard, bump the pin and resync.

### Source: `grafanaCom`

Fetches a published revision from the Grafana.com community dashboards catalog (`https://grafana.com/grafana/dashboards/<id>`).

```yaml
dashboards:
  node-exporter-full:
    source:
      grafanaCom:
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

- **source.grafanaCom.id** / **source.grafanaCom.revision**: Dashboard ID and revision number from grafana.com. The revision is the release identifier — never use "latest".
- **source.http.url**: Direct URL to dashboard JSON.
- **source.http.sha256** (optional): SHA-256 of the file. If provided, sync aborts on mismatch.
- **config.grafanaDashboardFolder** (optional): Target folder in Grafana. A folder resource is generated automatically.
- **config.uid** (optional): Dashboard UID. Defaults to the slugified dashboard name.
- **config.datasources** (optional): Map of `${PLACEHOLDER}` → datasource name. Most community dashboards use `${DS_PROMETHEUS}` etc.; this map substitutes them with the real datasource UIDs/names in your Grafana.

### Pipeline

1. **Sync**: `sync-dashboards` (also called by `sync-all-mixins`) downloads each pinned JSON to `/source/<env>/dashboards/<name>.json`.
2. **Render**: `render-grizzly-static-grafana-dashboards` (and the plain variant) wrap them as Grizzly `Dashboard` resources, applying the datasource substitutions.
3. **Apply**: handled by the same `apply-grizzly-grafana-dashboards` script as mixin-derived dashboards.

## SLO Configuration

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
