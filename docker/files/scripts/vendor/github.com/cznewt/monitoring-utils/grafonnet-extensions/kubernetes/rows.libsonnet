local g = import 'g.libsonnet';


function(config, variables) {
  local panels = (import './panels.libsonnet')(config, variables),
  local queries = (import './queries.libsonnet')(config, variables),

  toList(): [
    self.kubernetesDeployments,
    self.kubernetesPodResources,
    self.kubernetesContainerResources,
    self.kubernetesContainerLogs,
  ],

  kubernetesDeployments: [
    local y = if std.objectHas(config.y, 'kubernetesDeployments') then config.y.kubernetesDeployments else 0;
    panels.table.instances('Instances', queries.kubernetesPodInstances)
    + { gridPos: { h: 8, w: 24, x: 0, y: y } },
  ],

  kubernetesPodResources:
    local y = if std.objectHas(config.y, 'kubernetesPodResources') then config.y.kubernetesPodResources else 0;
    [
      g.ext.panel.timeSeries.bytes('Pod memory usage', queries.kubernetesPodMemoryUsage)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.timeSeries.base('Pod CPU usage', queries.kubernetesPodCpuUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
      g.ext.panel.timeSeries.bytesPerSecond('Pod network I/O usage', queries.kubernetesPodNetworkIoUsage)
      + { gridPos: { h: 6, w: 12, x: 0, y: y + 6 } },
      g.ext.panel.timeSeries.bytesPerSecond('Pod disk I/O usage', queries.kubernetesPodDiskIoUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y + 6 } },
    ],

  kubernetesContainerResources:
    local y = if std.objectHas(config.y, 'kubernetesContainerResources') then config.y.kubernetesContainerResources else 0;
    [
      g.ext.panel.timeSeries.bytes('Container memory usage', queries.kubernetesContainerMemoryUsage)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.timeSeries.base('Container CPU usage', queries.kubernetesContainerCpuUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

  kubernetesContainerLogs:
    local y = if std.objectHas(config.y, 'kubernetesContainerLogs') then config.y.kubernetesContainerLogs else 0;
    [
      g.ext.panel.timeSeries.short('Logs summary', queries.kubernetesContainerLogsAggregation)
      + { gridPos: { h: 8, w: 24, x: 0, y: y } },
      g.ext.panel.logs.base('Logs details', queries.kubernetesContainerLogs)
      + { gridPos: { h: 8, w: 24, x: 0, y: y + 8 } },
    ],

}
