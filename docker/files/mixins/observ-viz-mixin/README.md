# observ-viz mixin

Wraps a [observ-viz](https://github.com/cznewt/observ-viz) scenario as a
monitor-tools mixin: dashboards are schema v2 (`dashboard.grafana.app/v2beta1`),
so use `grafana.render: grafanactl`, and add
`jpaths: [vendor/github.com/cznewt/observ-viz]` to the mixin config. Select the
scenario with `config.scenario` (`platform`, `monlab`, `kubernetes`, `lgtm`,
`linux-server`, ...). Alerts and recording rules flow through mimirtool as for
any other mixin.

Three `config.scenario` values are not scenarios:

* `reference` renders the reference library (Panels / Runtimes / Common /
  Deployments).
* `base` renders the site's base layer — `Base / Home`, `Base / Clusters` and
  `Base / Cluster` from `libs/common-lib/base.libsonnet` (tabbed native v2),
  plus the `base:cluster_nodes:n` recording rule the Cluster board's
  `$nodecount` reads and the `Watchdog` alert.
* `libs` renders a list of observ-viz libraries (dotted `g.libs` paths) - each
  library's boards in the folder it files them into (Platform / Kubernetes,
  Workloads / Gaming, ...) plus its alert and recording groups. `libConfig`
  maps a library name to the config its `new()` gets. Identical groups that
  two libraries both emit (a library embedding another pack) are kept once;
  two different groups under one name fail the render, because a Mimir
  namespace holds a group name once.

  ```yaml
  observ-viz-libs:
    config:
      scenario: libs
      mimirNamespace: observ-viz-libs
      libs: [kubernetes.cluster, services.mimir, applications.valheim]
      libConfig:
        applications.valheim: { ruleSelector: 'namespace="gedu-valheim"' }
  ```

All three name their own Grafana folder in each board's metadata, so the config's
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
