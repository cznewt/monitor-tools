# Monitor Tools

A collection of tools and scripts for managing monitoring resources as a code. This toolkit simplifies the process of developing, linting, and deploying Grafana dashboards, Prometheus/Mimir rules, Loki rules, and SLOs.

- **Syncing**: Fetch and manage external mixins and libraries using `vendir` (e.g., `sync-mixins`).
- **Rendering**: Convert Jsonnet/Libsonnet templates into ready-to-use JSON/YAML resources (e.g., `render-resources`).
- **Linting**: Validate the syntax and correctness of generated resources (e.g., `lint-resources`).
- **Applying**: Deploy resources to services like Grafana, Mimir, and Loki (e.g., `apply-resources`).

## Docker Images

The project provides the following Docker images:

- **Monitor Tools**: `ghcr.io/cznewt/monitor-tools:latest`
  - Base image containing all necessary tools (Jsonnet, Grizzly, Mimirtool, etc.).
- **Jupyter Monitor Tools**: `ghcr.io/cznewt/jupyter-monitor-tools:latest`
  - JupyterLab environment pre-configured with Jsonnet language server and monitor tools.

## Usage

### Local development and testing

Use the following commands to manage your mixins locally:

```
#!/usr/bin/env just --justfile

default:
  just --list

install-vendor:
    @echo "Installing dependencies..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest install-standalone-mixin

clean-vendor:
	  @rm -rf vendor
	  @rm jsonnetfile.lock.json

clean-builds:
	  @rm -rf out

format-jsonnet:
    @echo "Formatting jsonnet files..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest format-standalone-mixin

render-grafana-dashboards:
    @echo "Rendering grafana dashboards to out/grafana_dashboards..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest render-standalone-grafana-dashboards

render-prometheus-alerts:
    @echo "Rendering prometheus alerts to out/prometheus_alerts..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest render-standalone-prom-alerts

lint-grafana-dashboards:
    @echo "Linting grafana dashboards at out/grafana_dashboards..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest lint-standalone-grafana-dashboards

lint-prometheus-alerts:
    @echo "Linting prometheus alerts at out/prometheus_alerts..."
    @docker run --rm -v $(pwd):/source ghcr.io/cznewt/monitor-tools:latest lint-standalone-prom-alerts
```

### As service

For a full automation run (sync, render, lint, and apply), you can use the high-level orchestration script:

```bash
sync-all-mixins
init-all-mixins
render-all-resources
```

## Tools

| Tool | Version | Description |
| :--- | :--- | :--- |
| **[Just](https://github.com/casey/just)** | 1.43.0 | Command runner for automation. |
| **[Vendir](https://github.com/carvel-dev/vendir)** | 0.44.0 | Directory syncing tool. |
| **[uv](https://github.com/astral-sh/uv)** | 0.9.28 | Python package installer. |
| **[YQ](https://github.com/mikefarah/yq)** | Latest | YAML processor. |
| **[Jsonnet](https://github.com/google/go-jsonnet)** | 0.21.0 | Data templating language. |
| **[Grizzly](https://github.com/grafana/grizzly)** | 0.7.1 | Grafana-as-code toolkit. |
| **[Mimirtool](https://github.com/grafana/mimir)** | 3.0.0 | Mimir & Alertmanager CLI. |
| **[LogCLI](https://github.com/grafana/loki)** | 3.5.7 | Loki CLI. |
| **[Sloth](https://github.com/slok/sloth)** | v0.15.0 | SLO management tool. |
| **[Pyrra](https://github.com/pyrra-dev/pyrra)** | 0.9.0 | SLO management tool. |

### Documentation

- [Scripts Documentation](docs/scripts.md)
- [Software Documentation](docs/software.md)
- [Configuration Documentation](docs/configuration.md)
- [Mixins Documentation](docs/mixins.md)
