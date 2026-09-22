{
  prometheusRules+:: {
    groups+: [
      {
        name: $._config.kubernetesEventsRuleGroup,
        interval: '1m',
        rules: [
          {
            record: 'cluster_namespace_kind_reason:kubernetes_events:count1m',
            expr: 'sum by (cluster, namespace, kind, reason, level) (count_over_time({%(kubernetesEventsSelector)s}[1m]))' % $._config,
          },
          {
            record: 'cluster_level:kubernetes_events:count1m',
            expr: 'sum by (cluster, level) (count_over_time({%(kubernetesEventsSelector)s}[1m]))' % $._config,
          },
        ],
      },
    ],
  },
}
