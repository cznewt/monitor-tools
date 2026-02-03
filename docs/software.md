# Software Documentation

This document lists the software and tools installed in the `monitor-tools` Docker image, as defined in `monitor-tools/docker/Dockerfile`.

## Core Tools

| Tool | Version | Description |
| :--- | :--- | :--- |
| [Just](https://github.com/casey/just) | 1.43.0 | A handy command runner. |
| [YQ](https://github.com/mikefarah/yq) | Latest | A portable command-line YAML processor. |
| [Go](https://go.dev/) | 1.25.3 | Go programming language runtime. |
| [Vale](https://github.com/errata-ai/vale) | 3.13.0 | A syntax-aware linter for prose. |
| [Vendir](https://github.com/carvel-dev/vendir) | 0.44.0 | Declarative way to sync any number of directories from different sources. |
| [uv](https://github.com/astral-sh/uv) | 0.9.28 | An extremely fast Python package installer and resolver. |

## Jsonnet Ecosystem

| Tool | Version | Description |
| :--- | :--- | :--- |
| [Go-Jsonnet](https://github.com/google/go-jsonnet) | 0.21.0 | Google's implementation of Jsonnet in Go. |
| [Jrsonnet](https://github.com/CertainLach/jrsonnet) | 0.5.0-pre96-test | A fast Jsonnet implementation in Rust. |
| [JB (Jsonnet Bundler)](https://github.com/jsonnet-bundler/jsonnet-bundler) | 0.6.0 | Package manager for Jsonnet. |
| [Mixtool](https://github.com/monitoring-mixins/mixtool) | Latest | Helper for working with Prometheus Mixins. |

## Monitoring Tools

### Grafana
| Tool | Version | Description |
| :--- | :--- | :--- |
| [Grizzly (grr)](https://github.com/grafana/grizzly) | 0.7.1 | A toolkit for managing Grafana resources as code. |
| [Grafanactl](https://github.com/grafana/grafanactl) | 0.1.7 | CLI tool for interacting with Grafana. |
| [Dashboard Linter](https://github.com/grafana/dashboard-linter) | Latest | Linter for Grafana dashboards. |

### Prometheus & Mimir
| Tool | Version | Description |
| :--- | :--- | :--- |
| [Promtool (Prometheus)](https://github.com/prometheus/prometheus) | 3.7.3 | CLI tool for Prometheus rules and config. |
| [Mimirtool](https://github.com/grafana/mimir) | 3.0.0 | CLI tool for managing Mimir and Alertmanager. |
| [Amtool (Alertmanager)](https://github.com/prometheus/alertmanager) | 0.29.0 | CLI for Alertmanager. |
| [Pint](https://github.com/cloudflare/pint) | 0.76.1 | Prometheus rule linter. |

### Loki
| Tool | Version | Description |
| :--- | :--- | :--- |
| [LogCLI](https://github.com/grafana/loki) | 3.5.7 | Command-line interface to Grafana Loki. |

### SLO Tools
| Tool | Version | Description |
| :--- | :--- | :--- |
| [Sloth](https://github.com/slok/sloth) | v0.15.0 | SLO generator and manager. |
| [Pyrra](https://github.com/pyrra-dev/pyrra) | 0.9.0 | SLO manager and service level objective tool. |

## Python Environment

The image is based on `quay.io/jupyter/datascience-notebook:notebook-7.4.7` and includes additional packages:

- `tsfresh`: Automatic extraction of relevant features from time series.
- `scikit-learn`: Machine learning library.
- `pyEDM`: Empirical Dynamic Modeling for time series.
- `pandas-datareader`: Up-to-date remote data access for pandas.
- `papermill`: Tool for parameterizing and executing Jupyter Notebooks.
- `seaborn`: Statistical data visualization.
- `statsmodels`: Statistical modeling and econometrics.
- `jupyterthemes`: Custom themes for Jupyter.

## System Packages

Standard utilities installed via `apt`:
`curl`, `ssh-client`, `git`, `wget`, `jq`, `vim`, `netcat-traditional`, `unzip`, `ca-certificates`, `gnupg`.
