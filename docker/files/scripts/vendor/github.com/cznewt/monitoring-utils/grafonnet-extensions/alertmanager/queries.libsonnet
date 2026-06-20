local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local alertmanagerQuery = g.ext.query.alertmanger;

function(config, variables) {

  clusterCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity="critical",cluster=~"$cluster"'),

  clusterNonCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity!="critical",cluster=~"$cluster"'),

  nodeCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity="critical",cluster=~"$cluster", node=~"$node"'),

  nodeNonCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity!="critical",cluster=~"$cluster", node=~"$node"'),

  podCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity="critical", cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"'),

  podNonCriticalAlerts:
    alertmanagerQuery.withDatasource('$' + variables.am_datasource.name)
    + alertmanagerQuery.withFilters('severity!="critical", cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"'),

}
