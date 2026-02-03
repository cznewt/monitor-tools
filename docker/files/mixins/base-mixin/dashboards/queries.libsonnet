local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;

function(config, variables) {

  base:
    prometheusQuery.withInstant(true)
    + prometheusQuery.withRange(false)
    + prometheusQuery.withFormat('table'),

  clusters:
    [
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(node_os_info{%(clusterVariableSelector)s}) by (%(clusterLabel)s)
        ||| % config
      )
      + self.base,
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(ALERTS{alertstate="firing", %(clusterVariableSelector)s}) by (%(clusterLabel)s)
        ||| % config
      )
      + self.base,
    ],

  envApps:
    [
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(up{%(clusterVariableSelector)s, %(appPartOfLabel)s=~".+"}) by ( %(appPartOfLabel)s)
        ||| % config
      )
      + self.base,
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(ALERTS{alertstate="firing", %(clusterVariableSelector)s, %(appPartOfLabel)s=~".+"}) by ( %(appPartOfLabel)s)
        ||| % config
      )
      + self.base,
    ],

  clusterApps:
    [
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(up{%(clusterVariableSelector)s, %(clusterLabel)s=~"$cluster", %(appPartOfLabel)s=~".+"}) by (%(appPartOfLabel)s)
        ||| % config
      )
      + self.base,
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          count(ALERTS{alertstate="firing", %(clusterVariableSelector)s, %(clusterLabel)s=~"$cluster", %(appPartOfLabel)s=~".+"}) by ( %(appPartOfLabel)s)
        ||| % config
      )
      + self.base,
    ],

  windowsServers:
    g.ext.base.queries.prometheus.tableQuery(variables, [
      'sum by (cluster, node) (windows_os_info{%(windowsQuerySelector)s})' % config,
      |||
        100 - 100 * (
          sum by (cluster, node) (rate(windows_cpu_time_total{%(windowsQuerySelector)s,mode="idle"}[5m]))
          /
          sum by (cluster, node) (rate(windows_cpu_time_total{%(windowsQuerySelector)s}[5m]))
        )
      ||| % config,
      |||
        100 - 100 * (
          (
            sum by (cluster,node) (windows_os_physical_memory_free_bytes{%(windowsQuerySelector)s})
          )
          /
          sum by (cluster,node) (windows_cs_physical_memory_bytes{%(windowsQuerySelector)s})
        )
      ||| % config,
      'max by (cluster, node) (time() - windows_system_system_up_time{%(windowsQuerySelector)s})' % config,
    ]),

  linuxServers:
    g.ext.base.queries.prometheus.tableQuery(variables, [
      'sum by (cluster, node, release) (node_uname_info{%(linuxQuerySelector)s})' % config,
      |||
        sum by (cluster, node) (
          (100 - 100 * rate(node_cpu_seconds_total{%(linuxQuerySelector)s, mode="idle"}[5m]))
          / ignoring(cpu) group_left
          count without (cpu)( node_cpu_seconds_total{%(linuxQuerySelector)s, mode="idle"})
        )
      ||| % config,
      |||
        100 -
        (
          100 *
          avg(node_memory_MemAvailable_bytes{%(linuxQuerySelector)s}) by (cluster, node)
          /
          avg(node_memory_MemTotal_bytes{%(linuxQuerySelector)s}) by (cluster, node)
        )
      ||| % config,
      'max by (cluster, node) (time() - node_boot_time_seconds{%(linuxQuerySelector)s})' % config,
    ]),
}

/**
clusterWindowsNodesStatsRow(config)::
    g.row('Windows Servers Overview')
    .addPanel(
      g.panel('Server Statistics') +
      g.tablePanel([
        'sum by (cluster,node,product,version) (windows_os_info{%(windowsQuerySelector)s})' % config,
      ], {
        cluster: { alias: 'Cluster' },
        node: { alias: 'Server' },
        product: { alias: 'OS' },
        version: { alias: 'Version' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),
  clusterLinuxNodesStatsRow(config)::
    g.row('Linux Servers Overview')
    .addPanel(
      g.panel('Server Statistics') +
      g.tablePanel([
        'sum by (cluster,node,product,version) (node_os_info{%(linuxQuerySelector)s})' % config,
      ], {
        cluster: { alias: 'Cluster' },
        node: { alias: 'Server' },
        product: { alias: 'OS' },
        version: { alias: 'Version' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),
  clusterWorkloadStatsRow(config)::
    g.row('Workload Overview')
    .addPanel(
      g.panel('Service Stats') +
      g.tablePanel([
        'sum by (cluster,app_part_of,app_component) (up{%(appQuerySelector)s,node=~"[a-z0-9]+"})' % config,
      ], {
        app_part_of: { alias: 'System' },
        app_component: { alias: 'Component' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),
 */