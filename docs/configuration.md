# Configuration Documentation

The `monitor-tools` uses YAML configuration files to define how monitoring resources are synced, rendered, and applied. These files are typically located in `/config` within the Docker container (mapped to `docker/files/config` locally).

## Global Structure

The configuration file generally contains the following top-level keys:

- `name`: The environment name (e.g., `default`).
- `prometheus`: Settings for Prometheus resource rendering (e.g., `render: mimirtool`).
- `grafana`: Settings for Grafana resource rendering (e.g., `render: grizzly`).
- `mixins`: A map of mixin definitions.
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
