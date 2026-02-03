# Monitor-Tools Scripts Documentation

This document describes the various scripts available in the `monitor-tools` project, located at `monitor-tools/docker/files/scripts`. These scripts are used for managing monitoring resources like Grafana dashboards, Prometheus/Mimir rules, Loki rules, and Alertmanager configurations.

## Overview

The scripting architecture relies on:
- **Jsonnet**: For templating monitoring resources.
- **Mixins**: Modular Prometheus and Grafana configurations.
- **Grizzly (`grr`)**: For managing Grafana resources.
- **Mimirtool**: For managing Mimir and Alertmanager resources.
- **Lokitool**: For managing Loki rules.
- **Vendir**: For syncing mixins and libraries from external sources.

## Configuration & Environment Variables

Most scripts use the following environment variables. Specific requirements are listed per script below.

- `CONFIG_FILE`: Path to the YAML configuration file (default: `/config/default.yaml`).
- `CONFIG_DIR`: Directory containing configuration files (default: `/config`).
- `SOURCE_DIR`: Directory containing mixin sources (default: `/source/default`).
- `BUILD_DIR`: Directory where rendered resources are stored (default: varies by script).
- `GRAFANA_URL`: URL of the Grafana server (required for `apply-*` scripts).
- `GRAFANA_TOKEN`: API token for Grafana (required for `apply-*` scripts).
- `MIMIR_ADDRESS`: URL of the Mimir server.
- `MIMIR_TENANT_ID`: Tenant ID for Mimir operations.
- `LOKI_ADDRESS`: URL of the Loki server.
- `LOKI_TENANT_ID`: Tenant ID for Loki operations.

## High-Level Orchestration

These scripts orchestrate multiple specialized scripts based on the configuration file.

- `do-all`: Runs `init-all-mixins`, `sync-all-mixins`, `render-all-resources`, `lint-all-resources`, and `apply-all-resources`. (Env: `CONFIG_DIR`)
- `init-all-mixins` / `sync-all-mixins`: Initialize and sync all mixins defined in the config. (Env: `CONFIG_DIR`)
- `render-all-resources`: Renders all resources (Grafana, Mimir, Loki, etc.) for all environments. (Env: `CONFIG_DIR`)
- `lint-all-resources`: Lints all rendered resources. (Env: `CONFIG_DIR`)
- `apply-all-resources`: Applies all rendered resources to their respective targets. (Env: `CONFIG_DIR`)
- `render-resources`: Renders resources for a specific configuration. (Env: `CONFIG_FILE`, `ENV_NAME`)
- `lint-resources`: Lints resources for a specific configuration. (Env: `CONFIG_FILE`)
- `apply-resources`: Applies resources for a specific configuration. (Env: `CONFIG_FILE`)

## Initialization & Syncing

Used to fetch and manage external mixins and libraries.

- `init-mixins`: Prepares the `vendir` configuration for mixins. (Env: `CONFIG_FILE`)
- `sync-mixins`: Syncs mixins and libraries using `vendir`. (Env: `CONFIG_FILE`, `SOURCE_DIR`)
- `vendor`: Manages the `/scripts/vendor` directory.

## Rendering Resources

These scripts convert Jsonnet/Libsonnet files into JSON/YAML resources.
Common Env: `CONFIG_FILE`, `SOURCE_DIR`, `BUILD_DIR`

### Grafana
- `render-grizzly-grafana-folders`: Renders Grafana folders using Grizzly.
- `render-grizzly-grafana-dashboards`: Renders Grafana dashboards using Grizzly.
- `render-plain-grafana-dashboards`: Renders raw JSON Grafana dashboards.
- `render-grizzly-grafana-datasources`: Renders Grafana datasources using Grizzly.

### Prometheus & Mimir
- `render-mimirtool-mimir-rules`: Renders Mimir alerting and recording rules.
- `render-plain-prom-rules`: Renders plain Prometheus rules.
- `render-mimirtool-alertmanager-config`: Renders Alertmanager configuration for Mimir.

### SLOs (Pyrra & Sloth)
- `render-pyrra-rules`: Renders Pyrra SLO definitions.
- `render-sloth-rules`: Renders Sloth SLO definitions.
- `render-plain-pyrra-prom-rules`: Renders Prometheus rules from Pyrra SLOs.
- `render-plain-sloth-prom-rules`: Renders Prometheus rules from Sloth SLOs.

### Loki
- `render-lokitool-loki-rules`: Renders Loki alerting and recording rules.

## Linting Resources

Validates the syntax and correctness of rendered resources.
Common Env: `BUILD_DIR`

- `lint-mimirtool-mimir-rules`: Lints Mimir rules using `mimirtool`.
- `lint-lokitool-loki-rules`: Lints Loki rules using `lokitool`.
- `lint-plain-grafana-dashboards`: Lints plain Grafana dashboard JSONs.
- `lint-plain-prom-rules`: Lints plain Prometheus rules.
- `lint-mimirtool-alertmanager-config`: Lints Alertmanager configuration.

## Applying Resources

Pushes the rendered and linted resources to the respective services.

- `apply-grizzly-grafana-folders`: Pushes Grafana folders via Grizzly. (Env: `BUILD_DIR`, `GRAFANA_URL`, `GRAFANA_TOKEN`)
- `apply-grizzly-grafana-dashboards`: Pushes Grafana dashboards via Grizzly. (Env: `BUILD_DIR`, `GRAFANA_URL`, `GRAFANA_TOKEN`)
- `apply-grizzly-grafana-datasources`: Pushes Grafana datasources via Grizzly. (Env: `BUILD_DIR`, `GRAFANA_URL`, `GRAFANA_TOKEN`)
- `apply-mimirtool-mimir-rules`: Pushes rules to Mimir via `mimirtool`. (Env: `BUILD_DIR`, `MIMIR_ADDRESS`, `MIMIR_TENANT_ID`)
- `apply-lokitool-loki-rules`: Pushes rules to Loki via `lokitool`. (Env: `BUILD_DIR`, `LOKI_ADDRESS`, `LOKI_TENANT_ID`)
- `apply-mimirtool-alertmanager-config`: Pushes Alertmanager config to Mimir. (Env: `BUILD_DIR`, `MIMIR_ADDRESS`, `MIMIR_TENANT_ID`)

## Utility Scripts

- `status`: Shows the status of the current configuration (mixins and libs found). (Env: `CONFIG_FILE`, `SOURCE_DIR`)
- `status-all`: Shows status for all environments. (Env: `CONFIG_DIR`)
- `version`: Displays versions of the tools (jsonnet, grizzly, etc.).
- `clean-build`: Cleans up the `/build` directory.
- `analyze-mimirtool-mimir-rules`: Analyzes Mimir rules for efficiency. (Env: `BUILD_DIR`)
- `analyze-plain-grafana-dashboards`: Analyzes Grafana dashboards. (Env: `BUILD_DIR`)
