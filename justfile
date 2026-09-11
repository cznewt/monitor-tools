#!/usr/bin/env just --justfile

default:
  just --list

# Test rendering and linting for a specific configuration
test-config +CONFIG:
    @echo "Testing {{CONFIG}} config..."
    docker run --rm -e CONFIG_NAME={{CONFIG}} ghcr.io/cznewt/monitor-tools:latest test-render-lint

# Run container
run-container:
    @echo "Running container..."
    docker run --rm -it ghcr.io/cznewt/monitor-tools:latest

# --- App instrumentation demo stacks (extra/app-instrumentation) ---
# Multi-language sample apps emitting one signal each through Alloy. They default
# to a bundled local backend; copy extra/app-instrumentation/.env.example to .env
# to forward to a remote Mimir/Loki/Tempo or Grafana Cloud. Run one at a time.

_instrumentation DIR:
    docker compose -f extra/app-instrumentation/{{DIR}}/docker-compose.yml up --build

# Logs from 7 languages -> Alloy -> Loki + Grafana
instrumentation-logging:
    @just _instrumentation logging/popular-logging-frameworks

# Prometheus-client /metrics from 5 languages -> Alloy -> Prometheus + Grafana
instrumentation-metrics-prom:
    @just _instrumentation metrics/prometheus-client

# OTLP metrics from 5 languages -> Alloy -> Prometheus + Grafana
instrumentation-metrics-otel:
    @just _instrumentation metrics/opentelemetry-sdk

# OTLP traces from 5 languages -> Alloy -> Tempo + Grafana
instrumentation-traces:
    @just _instrumentation traces/opentelemetry-sdk

# Tear down every instrumentation stack (volumes included)
instrumentation-clean:
    -docker compose -f extra/app-instrumentation/logging/popular-logging-frameworks/docker-compose.yml down -v
    -docker compose -f extra/app-instrumentation/metrics/prometheus-client/docker-compose.yml down -v
    -docker compose -f extra/app-instrumentation/metrics/opentelemetry-sdk/docker-compose.yml down -v
    -docker compose -f extra/app-instrumentation/traces/opentelemetry-sdk/docker-compose.yml down -v

# --- Alertmanager action handler demo (extra/alert-handler) ---
# Prometheus fires a demo alert, Alertmanager posts it to alert-handler, and the
# handler runs the rule's actions (a runbook command and an HTTP call; the
# Kubernetes actions are commented out because compose has no API server).
# Needs the image: build it once from the service catalog with
#   cd <service-catalog>/monitor-services/alert-handler && just container-build
# Host ports are overridable, e.g. `PROMETHEUS_PORT=19090 just alert-handler-demo`.

# Alertmanager -> alert-handler -> actions, on Prometheus + Alertmanager
alert-handler-demo:
    docker compose -f extra/alert-handler/docker-compose.yml up

# Follow what the handler did with each alert
alert-handler-demo-logs:
    docker compose -f extra/alert-handler/docker-compose.yml logs -f alert-handler

# Tear the demo down (volumes included)
alert-handler-demo-clean:
    -docker compose -f extra/alert-handler/docker-compose.yml down -v
