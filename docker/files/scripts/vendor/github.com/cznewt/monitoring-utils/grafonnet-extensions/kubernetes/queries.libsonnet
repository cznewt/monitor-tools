local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local lokiQuery = g.query.loki;

function(config, variables) {

  kubernetesPodInstances:
    g.ext.base.queries.prometheus.tableQuery(variables, [
      'count by (%(podLabels)s, %(appLabels)s, app_version, node) (up{%(podSelector)s})' % config,
      'time() - max by (%(queryLabels)s, node) (process_start_time_seconds{%(podSelector)s})' % config,
      'sum by (%(podLabels)s) (container_memory_rss{%(containerSelector)s})' % config,
      |||
        sum by (%(podLabels)s) (
          node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{%(containerSelector)s}
        )
      ||| % config,
    ]),

  kubernetesContainerLogsAggregation:
    lokiQuery.new(
      '$' + variables.loki_datasource.name,
      |||
        sum(rate({%(containerSelector)s} |= "${logFilter}" [5m])) by (%(containerLabels)s)
      ||| % config,
    )
    + lokiQuery.withLegendFormat('%(containerLegend)s' % config),

  kubernetesContainerLogsSeverityAggregation:
    lokiQuery.new(
      '$' + variables.loki_datasource.name,
      |||
        sum(rate({%(containerSelector)s} |= "${logFilter}" [5m])) by (severity,%(containerLabels)s)
      ||| % config,
    )
    + lokiQuery.withLegendFormat('%(containerLegend)s' % config),

  kubernetesContainerLogs:
    lokiQuery.new(
      '$' + variables.loki_datasource.name,
      |||
        {%(containerSelector)s} |= "${logFilter}"
      ||| % config,
    ),

  kubernetesPodMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(container_memory_rss{%(podSelector)s}) by (%(podLabels)s)
      ||| % config,
    )
    + prometheusQuery.withLegendFormat('%(containerLegend)s' % config),

  kubernetesPodCpuUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        max(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{%(podSelector)s}) by (%(podLabels)s)
      ||| % config,
    )
    + prometheusQuery.withLegendFormat('%(containerLegend)s' % config),

  kubernetesPodNetworkIoUsage:
    g.ext.base.queries.prometheus.listQuery(
      variables,
      [
        'topk(50, sum(container_network_transmit_bytes_total{%(podSelector)s}) by (%(podLabels)s))' % config,
        'topk(50, sum(container_network_receive_bytes_total{%(podSelector)s}) by (%(podLabels)s))' % config,
      ],
      [
        '%(podLegend)s TX' % config,
        '%(podLegend)s RX' % config,
      ]
    ),

  kubernetesPodDiskIoUsage:
    g.ext.base.queries.prometheus.listQuery(
      variables,
      [
        'topk(50, sum(container_fs_reads_bytes_total{%(podSelector)s}) by (%(podLabels)s))' % config,
        'topk(50, sum(container_fs_writes_bytes_total{%(podSelector)s}) by (%(podLabels)s))' % config,
      ],
      [
        '%(podLegend)s reads' % config,
        '%(podLegend)s writes' % config,
      ]
    ),

  kubernetesContainerMemoryUsage:
    g.ext.base.queries.prometheus.listQuery(
      variables,
      [
        |||
          topk(50,
            sum(
              container_memory_rss{%(containerSelector)s}
            ) by (%(containerLabels)s)
          )
        ||| % config,
        |||
          max(
            kube_pod_container_resource_limits_memory_bytes{%(containerSelector)s}
          ) by (container)
        ||| % config,
      ],
      [
        '%(containerLegend)s' % config,
        'limit' % config,
      ]
    ),

  kubernetesContainerCpuUsage:
    g.ext.base.queries.prometheus.listQuery(
      variables,
      [
        |||
          topk(50,
            max(
              node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{%(containerSelector)s}
            ) by (%(containerLabels)s)
          )
        ||| % config,
        |||
          max(
            kube_pod_container_resource_limits_cpu_cores{%(containerSelector)s}
          ) by (container)
        ||| % config,
      ],
      [
        '%(containerLegend)s' % config,
        'limit' % config,
      ]
    ),

}
