local g = import 'g.libsonnet';
local var = g.dashboard.variable;

function(config) {

  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.generalOptions.withLabel('Data source'),

  cluster:
    var.query.new('cluster')
    + var.query.generalOptions.withLabel('Cluster')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      config.clusterLabel,
      'up{%(clusterVariableSelector)s}' % config
    ),

  clusters:
    self.cluster
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  node:
    var.query.new('node')
    + var.query.generalOptions.withLabel('Node')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'node',
      'node_os_info{%(clusterLabel)s=~"$cluster"}' % config
    ),

  nodes:
    self.node
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

}
