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
//   libs       a list of observ-viz libraries (dotted g.libs paths), e.g.
//              config: { scenario: libs, libs: [kubernetes.cluster,
//              services.mimir, applications.valheim] } - each library's boards
//              (in the folder the library files them into, e.g. Platform /
//              Kubernetes) plus its alert and recording groups. `rulesOnly`
//              lists libraries whose groups are merged but whose boards are
//              skipped (another mixin owns them); `libConfig` maps a library
//              name to the config passed to its new(); `rules: false` renders
//              the boards only (a site whose rules come from a scenario).
// All three carry their own Grafana folder in each board's metadata, so the
// config's grafanaDashboardFolder does not apply to them. `config.base` is passed
// to the board builders (clusterLabel / nodeLabel / appLabel / selector / titles /
// folder), e.g. config: { scenario: base, base: { appLabel: namespace } }.
{
  _config+:: { scenario: 'platform', base: {}, libs: [], rulesOnly: [], libConfig: {}, rules: true },
  local isReference = $._config.scenario == 'reference',
  local isBase = $._config.scenario == 'base',
  local isLibs = $._config.scenario == 'libs',
  // `libs`: resolve each dotted name under g.libs and build it
  local lookup(name) = std.foldl(function(o, k) o[k], std.split(name, '.'), (import 'g.libsonnet').libs),
  local build(n) = lookup(n).new(if std.objectHas($._config.libConfig, n) then $._config.libConfig[n] else {}),
  local libs = [build(n) for n in $._config.libs],
  // `rulesOnly`: libraries whose rule groups are wanted but whose boards another
  // mixin owns (system.systemd / processExporter / windowsService boards are
  // the reference library's Platform / Deployments boards, same uids)
  local ruleLibs = libs + [build(n) for n in $._config.rulesOnly],
  local libBoards = std.foldl(function(acc, lib) acc + (
    local dbs = if std.objectHas(lib.grafana, 'dashboards') then lib.grafana.dashboards
      else { [lib.config.uid + '.json']: lib.grafana.dashboard };
    { [k]: dbs[k].toResource() for k in std.objectFields(dbs) }
  ), libs, {}),
  // Libraries that embed another pack emit its groups again (Salt
  // infrastructure carries salt-jobs and salt-conformity): keep one copy of an
  // identical group, and fail on two different groups under one name - a Mimir
  // namespace holds a group name once, so the second would silently replace
  // the first.
  local dedupe(groups) = std.foldl(function(acc, g)
    local seen = [x for x in acc if x.name == g.name];
    if std.length(seen) == 0 then acc + [g]
    else if seen[0] == g then acc
    else error 'observ-viz libs: two different rule groups named "%s"' % g.name, groups, []),
  local libAlerts = dedupe(std.flattenArrays([
    if std.objectHas(lib, 'prometheus') then lib.prometheus.alerts else []
    for lib in ruleLibs
  ])),
  local libRules = dedupe(std.flattenArrays([
    if std.objectHas(lib, 'prometheus') && std.objectHas(lib.prometheus, 'rules') then lib.prometheus.rules else []
    for lib in ruleLibs
  ])),
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
    if isReference || isBase || isLibs then {}
    else (import 'scenarios/main.libsonnet')[$._config.scenario].asMonitoringMixin(),
  grafanaDashboards+::
    if isReference
    then { [name]: reference.grafanaDashboards[name].toResource() for name in std.objectFields(reference.grafanaDashboards) }
    else if isBase then baseBoards
    else if isLibs then libBoards
    else s.grafanaDashboards,
  prometheusAlerts+::
    if isBase
    then { groups: [{ name: 'base-watchdog', rules: [base.watchdogAlert] }] }
    else if isReference then { groups: [] }
    else if isLibs then { groups: if $._config.rules then libAlerts else [] }
    else s.prometheusAlerts,
  prometheusRules+::
    if isBase then { groups: baseRules }
    else if isReference then { groups: [] }
    else if isLibs then { groups: if $._config.rules then libRules else [] }
    else s.prometheusRules,
}
