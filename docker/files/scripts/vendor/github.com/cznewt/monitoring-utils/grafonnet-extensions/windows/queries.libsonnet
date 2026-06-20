local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local lokiQuery = g.query.loki;

function(config, variables) {

  windowsServiceMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(windows_process_private_bytes{%(podSelector)s}) by (%(podLabels)s)
      ||| % config,
    )
    + prometheusQuery.withLegendFormat('%(containerLegend)s' % config),

  windowsServiceCpuUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(windows_process_private_bytes{%(podSelector)s}) by (%(podLabels)s)
      ||| % config,
    )
    + prometheusQuery.withLegendFormat('%(containerLegend)s' % config),

  windowsServiceIoUsage:
    g.ext.base.queries.prometheus.listQuery(
      variables,
      [
        'sum(windows_process_io_bytes_total{mode="read",%(podSelector)s}) by (%(podLabels)s)' % config,
        'sum(windows_process_io_bytes_total{mode="write",%(podSelector)s}) by (%(podLabels)s)' % config,
        'sum(windows_process_io_bytes_total{mode="other",%(podSelector)s}) by (%(podLabels)s) > 0' % config,
      ],
      [
        '%(podLegend)s reads' % config,
        '%(podLegend)s writes' % config,
        '%(podLegend)s others' % config,
      ]
    ),

}
