# Mixins Documentation

Mixins are bundles of Prometheus alerts, recording rules, and Grafana dashboards. The `monitor-tools` project uses `vendir` to sync these mixins from their source repositories and `jsonnet` to render them.

## Configuration

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

## Usage

To use a mixin:

1.  **Add it to your config file**: Define the `source` (git URL and ref) and `config` block.
2.  **Sync**: Run `sync-all-mixins` (or `do-all`) to fetch the files.
3.  **Render**: Run `render-all-resources` to generate the rules and dashboards.
4.  **Apply**: Run `apply-all-resources` to push them to Grafana and Mimir.
