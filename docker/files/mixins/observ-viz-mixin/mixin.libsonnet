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
// `scenario: reference` is the exception: it renders the reference library
// (Panels / Runtimes / Common / Deployments) instead, and those boards carry
// their own nested Grafana folder, so the config's grafanaDashboardFolder is
// ignored for them.
{
  _config+:: { scenario: 'platform' },
  local isReference = $._config.scenario == 'reference',
  local reference = (import 'libs/reference-lib/mixin.libsonnet'),
  local s = if isReference then {} else (import 'scenarios/main.libsonnet')[$._config.scenario].asMonitoringMixin(),
  grafanaDashboards+:: if isReference then { [name]: reference.grafanaDashboards[name].toResource() for name in std.objectFields(reference.grafanaDashboards) } else s.grafanaDashboards,
  prometheusAlerts+:: if isReference then {} else s.prometheusAlerts,
  prometheusRules+:: if isReference then {} else s.prometheusRules,
}
