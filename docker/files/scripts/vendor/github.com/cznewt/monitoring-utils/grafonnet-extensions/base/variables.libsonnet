local g = import 'g.libsonnet';
local var = g.dashboard.variable;

{

  runbook: function(config) {

    toBaseList(): [
      self.datasource,
      self.loki_datasource,
      self.es_datasource,
      self.am_datasource,
    ],

    toList(): self.toBaseList(),

    datasource:
      var.datasource.new('datasource', 'prometheus')
      + var.datasource.generalOptions.withLabel('Prometheus'),

    loki_datasource:
      var.datasource.new('loki_datasource', 'loki')
      + var.datasource.generalOptions.withLabel('Loki'),

    es_datasource:
      var.datasource.new('es_datasource', 'elasticsearch')
      + var.datasource.generalOptions.withLabel('ElasticSearch'),

    am_datasource:
      var.datasource.new('am_datasource', 'camptocamp-prometheus-alertmanager-datasource')
      + var.datasource.generalOptions.withLabel('Alertmanager'),

  },

  env: function(config) {

    datasource:
      var.datasource.new('datasource', 'prometheus')
      + var.datasource.generalOptions.withLabel('Metrics'),

    loki_datasource:
      var.datasource.new('loki_datasource', 'loki')
      + var.datasource.generalOptions.withLabel('Logs'),

    am_datasource:
      var.datasource.new('am_datasource', 'camptocamp-prometheus-alertmanager-datasource')
      + var.datasource.generalOptions.withLabel('Alerts'),

  },

  cluster: function(config) self.env(config) {

    cluster:
      var.query.new('cluster')
      + var.query.generalOptions.withLabel('Cluster')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        config.clusterLabel,
        'node_dmi_info{%(clusterVariableSelector)s}' % config
      ),

    clusters:
      self.cluster
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),
  },

  node: function(config) self.cluster(config) {

    nodes:
      var.query.new('node')
      + var.query.generalOptions.withLabel('Node')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'node',
        'node_dmi_info{%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

  },

}
