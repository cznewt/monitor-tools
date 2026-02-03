local g = import 'g.libsonnet';

{
  grafanaDashboards+:: {
    local config = $._config,
    local dashboards = g.ext.base.dashboards(config),

    'base-home.json':
      local variables = g.ext.base.variables.env(config);
      local rows = (import './rows.libsonnet')(config, variables)
                   + g.ext.base.rows(config, variables)
                   + g.ext.alertmanager.rows(config, variables);

      dashboards.base('Base / Home', slug='home', tags=['env-level'])
      + g.dashboard.withVariables([
        variables.datasource,
        variables.am_datasource,
      ])
      + g.dashboard.withPanels(
        rows.homeDashboards
        + rows.homeResources
      ),

    'base-cluster.json':
      local variables = g.ext.base.variables.cluster(config);
      local rows = (import './rows.libsonnet')(config, variables)
                   + g.ext.alertmanager.rows(config, variables);

      dashboards.base('Base / Cluster', slug='cluster', tags=['cluster-level'])
      + g.dashboard.withVariables([
        variables.datasource,
        variables.am_datasource,
        variables.cluster,
      ])
      + g.dashboard.withPanels(
        rows.clusterResources
        + rows.clusterAlerts
      ),

  },
}
