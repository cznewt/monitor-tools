// observ-viz as a monitor-tools mixin. `jb install` vendors the repo at
// vendor/github.com/cznewt/observ-viz; the config must add that directory to
// the mixin's jpaths so the repo's own relative imports resolve:
//   mixins:
//     observ-viz:
//       source: { directory: { path: /mixins/observ-viz-mixin } }
//       jpaths: [vendor/github.com/cznewt/observ-viz]
//       config: { scenario: platform, grafanaDashboardFolder: Platform (observ-viz), mimirNamespace: observ-viz }
// One mixin = one scenario (scenarios/<name> in observ-viz): its v2 dashboard
// specs, merged alert groups and recording rules. Use grafana.render:
// grafanactl (app-platform API) — grizzly cannot push schema v2 boards.
{
  _config+:: { scenario: 'platform' },
  local s = (import 'scenarios/main.libsonnet')[$._config.scenario].asMonitoringMixin(),
  grafanaDashboards+:: s.grafanaDashboards,
  prometheusAlerts+:: s.prometheusAlerts,
  prometheusRules+:: s.prometheusRules,
}
