local g = import 'g.libsonnet';

function(config, variables) {
  local panels = (import './panels.libsonnet')(config, variables),
  local queries = (import './queries.libsonnet')(config, variables),

  homeDashboards:
    local y = if std.objectHas(config.y, 'homeDashboards') then config.y.homeDashboards else 0;
    [
      g.ext.panel.dashboardList.tag('Platform resources', ['resource'])
      + { gridPos: { h: 8, w: 6, x: 0, y: y } },
      g.ext.panel.dashboardList.tag('Platform services', ['platform'])
      + { gridPos: { h: 8, w: 6, x: 0, y: y + 8 } },
      g.ext.panel.dashboardList.tag('Monitoring runbooks', ['runbook'])
      + { gridPos: { h: 16, w: 6, x: 6, y: y } },
      g.ext.panel.dashboardList.tag('Base services', ['base'])
      + { gridPos: { h: 8, w: 6, x: 12, y: y } },
      g.ext.panel.dashboardList.tag('Monitoring services', ['monitor'])
      + { gridPos: { h: 8, w: 6, x: 12, y: y + 8 } },
      g.ext.panel.dashboardList.tag('Time-series analysis', ['analysis'])
      + { gridPos: { h: 8, w: 6, x: 18, y: y } },
      g.ext.panel.dashboardList.tag('Reference dashboards', ['reference'])
      + { gridPos: { h: 8, w: 6, x: 18, y: y + 8 } },
    ],

  homeResources:
    local y = if std.objectHas(config.y, 'homeResources') then config.y.homeResources else 0;
    [
      panels.table.clusters('Clusters', queries.clusters)
      + { gridPos: { h: 12, w: 12, x: 0, y: y } },
      panels.table.envApps('Applications', queries.envApps)
      + { gridPos: { h: 12, w: 12, x: 12, y: y } },
    ],

  clusterResources:
    local y = if std.objectHas(config.y, 'clusterServers') then config.y.clusterServers else 0;
    [
      panels.table.clusterApps('Workload', queries.clusterApps)
      + { gridPos: { h: 16, w: 12, x: 0, y: y } },
    ] +
    (if config.linuxEnabled then [
       panels.table.linuxServers('Linux servers', queries.linuxServers)
       + { gridPos: { h: if config.windowsEnabled then 8 else 16, w: 12, x: 12, y: y } },
     ] else []) +
    (if config.windowsEnabled then [
       panels.table.windowsServers('Windows servers', queries.windowsServers)
       + { gridPos: { h: if config.linuxEnabled then 8 else 16, w: 12, x: 12, y: y } },
     ] else []),
}
