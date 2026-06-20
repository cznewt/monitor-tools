local g = import 'g.libsonnet';
local var = g.dashboard.variable;


function(config) {

  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.generalOptions.withLabel('Metrics'),

  loki_datasource:
    var.datasource.new('loki_datasource', 'loki')
    + var.datasource.generalOptions.withLabel('Logs (Loki)'),

  es_datasource:
    var.datasource.new('es_datasource', 'elasticsearch')
    + var.datasource.generalOptions.withLabel('Logs (ES)'),

  am_datasource:
    var.datasource.new('am_datasource', 'camptocamp-prometheus-alertmanager-datasource')
    + var.datasource.generalOptions.withLabel('Alerts'),

  clusters:
    var.query.new('cluster')
    + var.query.generalOptions.withLabel('Cluster')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      config.clusterLabel,
      '{%(selector)s}' % config
    )
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  apps:
    var.query.new('app_name')
    + var.query.generalOptions.withLabel('App')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      config.appLabel,
      '{%(selector)s,%(clusterLabel)s=~"$cluster"}' % config
    )
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  namespaces:
    var.query.new('namespace')
    + var.query.generalOptions.withLabel('Namespace')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'namespace',
      '{app_name=~"$app_name",%(clusterLabel)s=~"$cluster"}' % config
    )
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  containers:
    var.query.new('container')
    + var.query.generalOptions.withLabel('Container')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'container',
      '{namespace=~"$namespace",%(clusterLabel)s=~"$cluster"}' % config
    )
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  nodes:
    var.query.new('node')
    + var.query.generalOptions.withLabel('Node')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'node',
      '{app_name=~"$app_name",%(clusterLabel)s=~"$cluster",namespace=~"$namespace"}' % config
    )
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(),

  logFilter:
    var.textbox.new('logFilter', default='')
    + var.textbox.generalOptions.withLabel('Log filter'),

}
