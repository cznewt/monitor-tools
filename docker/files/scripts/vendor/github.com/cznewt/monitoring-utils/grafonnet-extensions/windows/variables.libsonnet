local g = import 'g.libsonnet';
local var = g.dashboard.variable;

{

  service: function(config) {

    toList(): [
      self.datasource,
      self.loki_datasource,
      self.am_datasource,
      self.clusters,
      self.apps,
      self.containers,
      self.nodes,
    ],

    datasource:
      var.datasource.new('datasource', 'prometheus')
      + var.datasource.generalOptions.withLabel('Metrics'),

    loki_datasource:
      var.datasource.new('loki_datasource', 'loki')
      + var.datasource.generalOptions.withLabel('Logs'),

    am_datasource:
      var.datasource.new('am_datasource', 'camptocamp-prometheus-alertmanager-datasource')
      + var.datasource.generalOptions.withLabel('Alerts'),

    clusters:
      var.query.new('cluster')
      + var.query.generalOptions.withLabel('Cluster')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        config.clusterLabel,
        '{%(clusterVariableSelector)s}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    apps:
      var.query.new('app_name')
      + var.query.generalOptions.withLabel('App')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        config.appLabel,
        '{%(appSelector)s,%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    containers:
      var.query.new('container')
      + var.query.generalOptions.withLabel('Container')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'container',
        '{namespace=~"$namespace",pod=~"$pod",container!="POD",%(clusterLabel)s=~"$cluster"}' % config
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
  },
}
