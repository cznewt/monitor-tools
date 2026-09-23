// Base boards driven by a label hierarchy (config.baseSetups[<setup>]):
//   env-cluster-system: $env -> $cluster -> $system
//   system-env:         $system -> $env (cluster stays a column, not a variable)
// Each level variable lists the values under the levels chosen before it; All
// is '.*', which also matches series that lack the label. The home board
// carries the first level only, the detail board the whole chain.
local g = import 'g.libsonnet';
local var = g.dashboard.variable;
local prometheusQuery = g.query.prometheus;
local alertmanagerQuery = g.ext.query.alertmanger;
local table = g.panel.table;
local override = table.standardOptions.override;

function(config, setup) {
  local h = self,
  local levels = [config.baseLevels[l] { name: l } for l in setup.hierarchy],
  local sel(ls) = std.join(', ', ['%s=~"$%s"' % [l.label, l.name] for l in ls]),
  local join(parts) = std.join(', ', [p for p in parts if p != '']),
  local base = config.clusterVariableSelector,
  // cluster is always shown; a column when it is not a level
  local clusterCol = if std.member(setup.hierarchy, 'cluster') then [] else [config.clusterLabel],
  local nodeLevels = [l for l in levels if std.objectHas(l, 'onNodes') && l.onNodes],

  scope: join([base, sel(levels)]),
  // the home board carries the first level only
  homeScope: join([base, sel(levels[0:1])]),
  // node_exporter / windows_exporter series only carry the node-level labels
  nodeScope: join([base, sel(nodeLevels)]),
  detailUid: setup.detail.uid,

  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.generalOptions.withLabel('Metrics'),
  am_datasource:
    var.datasource.new('am_datasource', 'camptocamp-prometheus-alertmanager-datasource')
    + var.datasource.generalOptions.withLabel('Alerts'),

  levelVar(i)::
    local l = levels[i];
    var.query.new(l.name)
    + var.query.generalOptions.withLabel(l.title)
    + var.query.withDatasourceFromVariable(h.datasource)
    + var.query.queryTypes.withLabelValues(l.label, 'up{%s}' % join([base, sel(levels[0:i])]))
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(true, '.*')
    + var.query.refresh.onTime(),

  homeVariables: [h.datasource, h.am_datasource, h.levelVar(0)],
  detailVariables: [h.datasource, h.am_datasource] + [h.levelVar(i) for i in std.range(0, std.length(levels) - 1)],

  local tq(expr, ref) =
    prometheusQuery.new('$datasource', expr)
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRange(false)
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withRefId(ref),

  // one row per label combination: targets, targets down, firing alerts;
  // hierarchy columns link to the detail board with the row's values.
  local countsTable(title, by, selector, linkLevels) =
    local byStr = std.join(', ', by);
    g.ext.panel.table.base(title, [
      tq('count by (%s) (up{%s})' % [byStr, selector], 'A'),
      tq('count by (%s) (up{%s} == 0)' % [byStr, selector], 'B'),
      tq('count by (%s) (ALERTS{alertstate="firing", %s})' % [byStr, selector], 'C'),
    ])
    + table.queryOptions.withTransformations([
      { id: 'merge', options: {} },
      { id: 'organize', options: {
        excludeByName: { Time: true },
        indexByName: { [by[i]]: i for i in std.range(0, std.length(by) - 1) } + { 'Value #A': std.length(by), 'Value #B': std.length(by) + 1, 'Value #C': std.length(by) + 2 },
        renameByName: { [l.label]: l.title for l in levels } + { [config.clusterLabel]: 'Cluster', 'Value #A': 'Targets', 'Value #B': 'Down', 'Value #C': 'Firing alerts' },
      } },
    ])
    + table.standardOptions.withOverrides([
      override.byName.new(l.label)
      + override.byName.withProperty('links', [{
        title: 'Open %s' % setup.detail.title,
        url: '/d/%s?${__url_time_range}&%s' % [
          setup.detail.uid,
          std.join('&', ['var-%s=${__data.fields.%s}' % [k.name, k.label] for k in linkLevels]),
        ],
      }])
      for l in linkLevels
    ]),

  local amTable(title, severity, ls) =
    g.ext.panel.table.base(title, [
      alertmanagerQuery.withDatasource('$am_datasource')
      + alertmanagerQuery.withFilters(join(['severity%s"critical"' % severity, sel(ls)]))
      + alertmanagerQuery.withRefId('A'),
    ])
    + table.queryOptions.withTransformations([
      { id: 'organize', options: {
        indexByName: { alertname: 0, severity: 1, summary: 2 },
      } },
    ]),

  // home: the first two levels (plus cluster), linking to the detail board
  homePanels(y)::
    local top = levels[0:std.min(2, std.length(levels))];
    [
      countsTable('%s overview' % std.join(' / ', [l.title for l in top]), [l.label for l in top] + clusterCol, join([base, sel(levels[0:1])]), top)
      + { gridPos: { h: 12, w: 24, x: 0, y: y } },
    ],

  // detail: workload under the last level, then servers and alerts
  detailPanels(y)::
    local last = levels[std.length(levels) - 1];
    [
      countsTable('Workload by %s' % std.asciiLower(last.title), [last.label] + clusterCol + ['job'], h.scope, [])
      + { gridPos: { h: 12, w: 24, x: 0, y: y } },
    ],

  // alert tables filtered by the levels the board has variables for
  homeAlertPanels(y):: h.alertPanels(y, levels[0:1]),
  detailAlertPanels(y):: h.alertPanels(y, levels),
  alertPanels(y, ls)::
    [
      amTable('Critical alerts', '=', ls) + { gridPos: { h: 8, w: 12, x: 0, y: y } },
      amTable('Warnings', '!=', ls) + { gridPos: { h: 8, w: 12, x: 12, y: y } },
    ],
}
