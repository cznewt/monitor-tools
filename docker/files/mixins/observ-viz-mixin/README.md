# observ-viz mixin

Wraps a [observ-viz](https://github.com/cznewt/observ-viz) scenario as a
monitor-tools mixin: dashboards are schema v2 (`dashboard.grafana.app/v2beta1`),
so use `grafana.render: grafanactl`, and add
`jpaths: [vendor/github.com/cznewt/observ-viz]` to the mixin config. Select the
scenario with `config.scenario` (`platform`, `monlab`, `kubernetes`, `lgtm`,
`linux-server`, ...). Alerts and recording rules flow through mimirtool as for
any other mixin.

Two `config.scenario` values are not scenarios:

* `reference` renders the reference library (Panels / Runtimes / Common /
  Deployments).
* `base` renders the site's base layer — `Base / Home`, `Base / Clusters` and
  `Base / Cluster` from `libs/common-lib/base.libsonnet` (tabbed native v2),
  plus the `base:cluster_nodes:n` recording rule the Cluster board's
  `$nodecount` reads and the `Watchdog` alert.

Both name their own Grafana folder in each board's metadata, so the config's
`grafanaDashboardFolder` does not apply to them. Pass board config through
`config.base`, e.g. a site whose workloads are labelled by namespace:

```yaml
  observ-viz-base:
    config:
      scenario: base
      mimirNamespace: observ-viz-base
      base:
        appLabel: namespace
        selector: ''
    jpaths: [vendor/github.com/cznewt/observ-viz]
    source: { directory: { path: /mixins/observ-viz-mixin } }
```
