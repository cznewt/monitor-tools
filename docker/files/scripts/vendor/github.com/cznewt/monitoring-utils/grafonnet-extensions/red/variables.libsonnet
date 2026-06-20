{
  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.withRegex(datasourceRegex),

  cluster:
    var.query.new('cluster')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      config.clusterLabel,
      'request_duration_seconds_count{%s}' % variablesSelector,
    ),

  namespace:
    var.query.new('namespace')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'namespace',
      'request_duration_seconds_count{cluster="$%s", %s}' % [
        self.cluster.name,
        variablesSelector,
      ]
    ),

  toArray: [
    self.datasource,
    self.cluster,
    self.namespace,
  ],

  selector:
    'cluster="$%s",namespace="$%s"' % [
      self.cluster.name,
      self.namespace.name,
    ],
}
