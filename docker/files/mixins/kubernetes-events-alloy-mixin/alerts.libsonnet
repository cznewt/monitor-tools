{
  prometheusAlerts+:: {
    groups+: [
      {
        name: $._config.kubernetesEventsAlertGroup,
        interval: '1m',
        rules: [
          {
            alert: 'KubernetesEventWarningStorm',
            expr: 'sum by (cluster, namespace, reason) (count_over_time({%(kubernetesEventsSelector)s, level="Warning"}[10m])) > %(kubernetesEventsStormThreshold)d' % $._config,
            'for': '15m',
            labels: { severity: 'warning' },
            annotations: {
              summary: 'Namespace {{ $labels.namespace }} on {{ $labels.cluster }} is producing a stream of {{ $labels.reason }} warnings.',
              description: 'More than %(kubernetesEventsStormThreshold)d {{ $labels.reason }} warning events in 10 minutes, for 15 minutes.' % $._config,
            },
          },
          {
            alert: 'KubernetesNodePressureEvents',
            expr: 'sum by (cluster, node, reason) (count_over_time({%(kubernetesEventsSelector)s, reason=~"NodeNotReady|SystemOOM|Evicted|FreeDiskSpaceFailed|ImageGCFailed"}[10m])) > 0' % $._config,
            'for': '5m',
            labels: { severity: 'warning' },
            annotations: {
              summary: 'Node {{ $labels.node }} on {{ $labels.cluster }} reports {{ $labels.reason }}.',
              description: 'The kubelet has been reporting {{ $labels.reason }} events for 5 minutes; the node is short of memory, disk or is evicting pods.',
            },
          },
        ],
      },
    ],
  },
}
