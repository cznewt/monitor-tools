// observ-viz as a monitor-tools mixin. `jb install` vendors the repo at
// vendor/github.com/cznewt/observ-viz; the config must add that directory to
// the mixin's jpaths so the repo's own relative imports resolve:
//   mixins:
//     observ-viz:
//       source: { directory: { path: /mixins/observ-viz-mixin } }
//       jpaths: [vendor/github.com/cznewt/observ-viz]
//       config: { scenario: platform, grafanaDashboardFolder: Platform, mimirNamespace: observ-viz }
// One mixin = one scenario (scenarios/<name> in observ-viz): its v2 dashboard
// specs, merged alert groups and recording rules. Use grafana.render:
// grafanactl (app-platform API) — grizzly cannot push schema v2 boards.
//
// Two scenario names are not scenarios at all:
//   reference  the reference library (Panels / Runtimes / Common / Deployments)
//   base       the site's base layer — Base / Home, Base / Clusters and
//              Base / Cluster, the tabbed fleet boards from
//              libs/common-lib/base.libsonnet, plus the node-count recording
//              rule the Cluster board's $nodecount reads and the Watchdog alert.
// Both carry their own Grafana folder in each board's metadata, so the config's
// grafanaDashboardFolder does not apply to them. `config.base` is passed to the
// board builders (clusterLabel / nodeLabel / appLabel / selector / titles /
// folder), e.g. config: { scenario: base, base: { appLabel: namespace } }.
{
  _config+:: { scenario: 'platform', base: {} },
  local isReference = $._config.scenario == 'reference',
  local isBase = $._config.scenario == 'base',
  local reference = (import 'libs/reference-lib/mixin.libsonnet'),
  local base = (import 'libs/common-lib/base.libsonnet'),
  local baseBoards =
    local c = $._config.base;
    local boards = base.home.new(c).grafana.dashboards
                   + base.cluster.new(c).grafana.dashboards
                   + base.clusterDetail.new(c).grafana.dashboards;
    { [name]: boards[name].toResource() for name in std.objectFields(boards) },
  local baseRules = base.clusterDetail.new($._config.base).prometheus.rules,
  local s =
    if isReference || isBase then {}
    else (import 'scenarios/main.libsonnet')[$._config.scenario].asMonitoringMixin(),
  grafanaDashboards+::
    if isReference
    then { [name]: reference.grafanaDashboards[name].toResource() for name in std.objectFields(reference.grafanaDashboards) }
    else if isBase then baseBoards
    else s.grafanaDashboards,
  prometheusAlerts+::
    if isBase
    then { groups: [{ name: 'base-watchdog', rules: [base.watchdogAlert] }] }
    else if isReference then { groups: [] }
    else s.prometheusAlerts,
  prometheusRules+::
    if isBase then { groups: baseRules }
    else if isReference then { groups: [] }
    else s.prometheusRules,
}
