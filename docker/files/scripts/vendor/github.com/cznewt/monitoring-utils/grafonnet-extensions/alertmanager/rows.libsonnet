local g = import 'g.libsonnet';

function(config, variables) {

  local panels = (import './panels.libsonnet')(config, variables),
  local queries = (import './queries.libsonnet')(config, variables),

  nodeAlerts:
    local y = if std.objectHas(config.y, 'nodeAlerts') then config.y.nodeAlerts else 0;
    [
      g.ext.panel.table.base('Critial alerts', queries.nodeCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.table.base('Warnings', queries.nodeNonCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

  kubernetesPodAlerts:
    local y = if std.objectHas(config.y, 'kubernetesPodAlerts') then config.y.kubernetesPodAlerts else 0;
    [
      g.ext.panel.table.base('Critial alerts', queries.podCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.table.base('Warnings', queries.podNonCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

  clusterAlerts:
    local y = if std.objectHas(config.y, 'clusterAlerts') then config.y.clusterAlerts else 0;
    [
      panels.table.clusterAlerts('Critial alerts', queries.clusterCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      panels.table.clusterAlerts('Warnings', queries.clusterNonCriticalAlerts)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

}
