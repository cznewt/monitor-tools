# observ-viz mixin

Wraps a [observ-viz](https://github.com/cznewt/observ-viz) scenario as a
monitor-tools mixin: dashboards are schema v2 (`dashboard.grafana.app/v2beta1`),
so use `grafana.render: grafanactl`, and add
`jpaths: [vendor/github.com/cznewt/observ-viz]` to the mixin config. Select the
scenario with `config.scenario` (`platform`, `monlab`, `kubernetes`, `lgtm`,
`linux-server`, ...). Alerts and recording rules flow through mimirtool as for
any other mixin.
