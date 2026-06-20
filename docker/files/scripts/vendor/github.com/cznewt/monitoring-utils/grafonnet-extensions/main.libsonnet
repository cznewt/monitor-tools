{
  ext: {

    query: {
      alertmanger: (import 'query/alertmanager.libsonnet'),
      clickhouse: (import 'query/clickhouse.libsonnet'),
    },

    panel: {
      alertList: (import 'panel/alertList.libsonnet'),
      canvas: (import 'panel/canvas.libsonnet'),
      dashboardList: (import 'panel/dashboardList.libsonnet'),
      heatmap: (import 'panel/heatmap.libsonnet'),
      logs: (import 'panel/logs.libsonnet'),
      stat: (import 'panel/stat.libsonnet'),
      table: (import 'panel/table.libsonnet'),
      text: (import 'panel/text.libsonnet'),
      timeSeries: (import 'panel/timeSeries.libsonnet'),
    },

    alertmanager: {
      rows(config, variables): (import 'alertmanager/rows.libsonnet')(config, variables),
    },

    base: {
      config: (import 'base/config.libsonnet'),
      dashboards(config): (import 'base/dashboards.libsonnet')(config),
      queries: (import 'base/queries.libsonnet'),
      variables: (import 'base/variables.libsonnet'),
      rows(config, variables): (import 'base/rows.libsonnet')(config, variables),
    },

    golang: {
      config(config): (import 'platform/golang/config.libsonnet'),
      rows(config, variables): (import 'platform/golang/rows.libsonnet')(config, variables),
    },

    kubernetes: {
      config: (import 'kubernetes/config.libsonnet'),
      dashboard(config): (import 'kubernetes/dashboard.libsonnet'),
      dashboards(config): (import 'kubernetes/dashboards.libsonnet')(config),
      variables: (import 'kubernetes/variables.libsonnet'),
      rows(config, variables): (import 'kubernetes/rows.libsonnet')(config, variables),
    },

    jvm: {
      config: (import 'platform/jvm/config.libsonnet'),
      rows(config, variables): (import 'platform/jvm/rows.libsonnet')(config, variables),
    },

    python: {
      config: (import 'platform/python/config.libsonnet'),
      rows(config, variables): (import 'platform/python/rows.libsonnet')(config, variables),
    },

    windows: {
      config: (import 'windows/config.libsonnet'),
      dashboards(config): (import 'windows/dashboards.libsonnet')(config),
      variables: (import 'windows/variables.libsonnet'),
      rows(config, variables): (import 'windows/rows.libsonnet')(config, variables),
    },

  },

}
