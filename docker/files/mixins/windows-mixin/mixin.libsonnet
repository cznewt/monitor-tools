local g = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.0.0/main.libsonnet';
local var = g.dashboard.variable;
local winlib = import 'github.com/grafana/jsonnet-libs/windows-observ-lib/main.libsonnet';
local config = (import './config.libsonnet')._config;
{
  local windows =
    winlib.new()
    +
    {
      config+: config,
    },
    // + winlib.withConfigMixin(config),
  prometheusAlerts+:: windows.prometheus.alerts,
  grafanaDashboards+::
    (windows {
       grafana+: {
         variables+: {
           datasources+: {
             loki+: var.datasource.withRegex('Loki|.+logs'),
             prometheus+: var.datasource.withRegex('Prometheus|Cortex|Mimir|grafanacloud-.+-prom'),
           },
         },
       },
     })
    .grafana.dashboards,
}
