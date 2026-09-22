{
  _config+:: {
    // Kubernetes events as Alloy's eventhandler ships them (the k8s-monitoring
    // chart's clusterEvents feature). Its lines are logfmt and the stream
    // carries cluster, namespace, name, node, kind, reason and level labels.
    kubernetesEventsSelector: 'job="integrations/kubernetes/eventhandler"',
    // rule group names, so a config can list them under lokiRuleGroups
    kubernetesEventsRuleGroup: 'kubernetes-events-alloy.rules',
    kubernetesEventsAlertGroup: 'kubernetes-events-alloy',
    // a namespace/reason pair above this many events in 10 minutes is a storm
    kubernetesEventsStormThreshold: 200,
  },
}
