# Monitor Tools

A collection of tools and scripts for managing monitoring resources as a code. This toolkit simplifies the process of developing, linting, and deploying Grafana dashboards, Prometheus/Mimir rules, Loki rules, and SLOs.

- **Syncing**: Fetch and manage external mixins and libraries using `vendir` (e.g., `sync-mixins`).
- **Rendering**: Convert Jsonnet/Libsonnet templates into ready-to-use JSON/YAML resources (e.g., `render-resources`).
- **Linting**: Validate the syntax and correctness of generated resources (e.g., `lint-resources`).
- **Applying**: Deploy resources to services like Grafana, Mimir, and Loki (e.g., `apply-resources`).

## Docker Images

The project provides the following Docker images:

### Monitor Tools

Base image containing all necessary tools (Jsonnet, Grizzly, Mimirtool, etc.).

- `ghcr.io/cznewt/monitor-tools:latest`

### Jupyter Monitor Tools

JupyterLab environment pre-configured with Jsonnet language server and monitor tools.

- `ghcr.io/cznewt/jupyter-monitor-tools:latest`

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

### Docker Compose

For local iteration, mount your editable trees over the baked image. The repo
ships a `docker-compose.yml` for the JupyterLab variant — edit `.env` for any
apply-time credentials (`GRAFANA_URL`, `GRAFANA_TOKEN`, `MIMIR_ADDRESS`,
`MIMIR_TENANT_ID`, `LOKI_ADDRESS`, `LOKI_TENANT_ID`, …) and run:

```bash
docker compose up -d
# Open http://localhost:8888
```

To run a one-shot render/apply locally without Jupyter:

```bash
docker run --rm \
  --env-file .env \
  -v "$PWD/docker/files/config:/config" \
  -v "$PWD/docker/files/mixins:/mixins" \
  -v "$PWD/docker/files/scripts:/scripts" \
  ghcr.io/cznewt/monitor-tools:latest \
  do-all
```

### Helm

Two charts are published to GHCR as OCI artifacts:

```bash
# Headless: ConfigMap + Secret + Job (or CronJob) running do-all
helm install mt oci://ghcr.io/cznewt/charts/monitor-tools \
  --version 0.2.0 \
  -f my-values.yaml

# JupyterLab + monitor-tools with the same ConfigMap + Secret wiring
helm install jmt oci://ghcr.io/cznewt/charts/jupyter-monitor-tools \
  --version 0.2.0 \
  -f my-values.yaml
```

Both charts accept the same shape:

```yaml
# Inline configs (each entry becomes a file in /config)
configs:
  default.yaml: |
    name: default
    prometheus: { render: mimirtool }
    grafana: { render: grizzly }
    mixins: { ... }
# OR drop YAMLs into the chart's configs/ directory and they'll be picked up
# automatically via Files.Glob (configsDir defaults to "configs/*.yaml").

# Apply-time credentials — chart creates a Secret from these
env:
  GRAFANA_URL: https://grafana.example.com
  GRAFANA_TOKEN: <token>
  MIMIR_ADDRESS: https://mimir.example.com
  MIMIR_TENANT_ID: tenant-1

# OR reference a pre-existing Secret (skips chart-managed Secret)
existingSecret: my-monitor-tools-creds
```

The `monitor-tools` chart additionally exposes a `job:` block: set
`job.schedule` to render a `CronJob` instead of a one-shot `Job`, and tweak
`job.command` for `apply-resources`, `do-all && apply-resources`, etc.

## Tools

| Tool | Version | Description |
| :--- | :--- | :--- |
| **[Just](https://github.com/casey/just)** | 1.43.0 | Command runner for automation. |
| **[Vendir](https://github.com/carvel-dev/vendir)** | 0.44.0 | Directory syncing tool. |
| **[Jsonnet](https://github.com/google/go-jsonnet)** | 0.21.0 | Data templating language. |
| **[Grizzly](https://github.com/grafana/grizzly)** | 0.7.1 | Grafana-as-code toolkit. |
| **[Mimirtool](https://github.com/grafana/mimir)** | 3.0.0 | Mimir & Alertmanager CLI. |
| **[LogCLI](https://github.com/grafana/loki)** | 3.5.7 | Loki CLI. |
| **[Sloth](https://github.com/slok/sloth)** | v0.15.0 | SLO management tool. |
| **[Pyrra](https://github.com/pyrra-dev/pyrra)** | 0.9.3 | SLO management tool. |

### Documentation

- [Scripts Documentation](docs/scripts.md)
- [Software Documentation](docs/software.md)
- [Configuration Documentation](docs/configuration.md)
- [Mixins Documentation](docs/mixins.md)
