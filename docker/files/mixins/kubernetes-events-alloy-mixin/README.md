# kubernetes-events-alloy mixin

Recording rules and alerts over the Kubernetes events Alloy's eventhandler
ships (the k8s-monitoring chart's `clusterEvents` feature). They are LogQL
rules for a Loki ruler, so list both group names under the mixin's
`lokiRuleGroups` config.

The upstream `adinhodovic/kubernetes-events-mixin` expects OpenTelemetry field
names (`k8s_namespace_name`, `k8s_resource_kind`) inside JSON log lines; Alloy
writes logfmt lines and puts `cluster`, `namespace`, `name`, `node`, `kind`,
`reason` and `level` on the stream, so these rules group by those labels
instead.

```yaml
mixins:
  kubernetes-events-alloy:
    config:
      mimirNamespace: kubernetes-events
      lokiRuleGroups:
        - kubernetes-events-alloy.rules
        - kubernetes-events-alloy
    source:
      directory:
        path: /mixins/kubernetes-events-alloy-mixin
```
