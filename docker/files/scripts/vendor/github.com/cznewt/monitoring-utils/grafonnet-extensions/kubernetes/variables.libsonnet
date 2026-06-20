local g = import 'g.libsonnet';
local var = g.dashboard.variable;

{

  pod: function(config) {

    toList(): [
      self.datasource,
      self.loki_datasource,
      self.am_datasource,
      self.clusters,
      self.namespaces,
      self.pods,
      self.containers,
      self.nodes,
      self.logFilter,
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
        'up{%(selector)s,%(clusterVariableSelector)s}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    namespaces:
      var.query.new('namespace')
      + var.query.generalOptions.withLabel('Namespace')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'namespace',
        '{%(selector)s,%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    pods:
      var.query.new('pod')
      + var.query.generalOptions.withLabel('Pod')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'pod',
        '{%(selector)s,,%(clusterLabel)s=~"$cluster",namespace=~"$namespace"}' % config
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
        'node_dmi_info{%(appLabel)s=~"$app_name",%(clusterLabel)s=~"$cluster",namespace=~"$namespace"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    logFilter:
      var.textbox.new('logFilter', default='')
      + var.textbox.generalOptions.withLabel('Log filter'),
  },

  app: function(config) {

    toBaseList(): [
      self.datasource,
      self.loki_datasource,
      self.am_datasource,
      self.clusters,
      self.apps,
      self.namespaces,
      self.pods,
      self.containers,
      self.nodes,
      self.logFilter,
    ],

    toList(): self.toBaseList(),

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
        'up{%(clusterVariableSelector)s}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    apps:
      var.query.new('app_name')
      + var.query.generalOptions.withLabel('App')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        config.appLabel,
        'up{%(appSelector)s,%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    namespaces:
      var.query.new('namespace')
      + var.query.generalOptions.withLabel('Namespace')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'namespace',
        '{%(appLabel)s=~"$app_name",%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    pods:
      var.query.new('pod')
      + var.query.generalOptions.withLabel('Pod')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'pod',
        '{%(appLabel)s=~"$app_name",%(clusterLabel)s=~"$cluster",namespace=~"$namespace"}' % config
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
        'node_dmi_info{%(appLabel)s=~"$app_name",%(clusterLabel)s=~"$cluster",namespace=~"$namespace"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),

    logFilter:
      var.textbox.new('logFilter', default='')
      + var.textbox.generalOptions.withLabel('Log filter'),
  },

  pvc: function(config) {

    toList(): [
      self.datasource,
      self.loki_datasource,
      self.am_datasource,
      self.clusters,
      self.namespaces,
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

    namespaces:
      var.query.new('namespace')
      + var.query.generalOptions.withLabel('Namespace')
      + var.query.withDatasourceFromVariable(self.datasource)
      + var.query.queryTypes.withLabelValues(
        'namespace',
        '{%(clusterLabel)s=~"$cluster"}' % config
      )
      + var.query.selectionOptions.withMulti()
      + var.query.selectionOptions.withIncludeAll(),
  },

}
