local g = import 'g.libsonnet';

g.ext.base.config {
  queryLabels: (if self.showMultiCluster then self.clusterLabel + ',' else '') + 'namespace,pod',
  querySelector: std.join(',', ['%s=~"$%s"' % [label, label] for label in std.split(self.queryLabels, ',')]),
  queryLegend: std.join(' ', ['{{%s}}' % [label] for label in std.split(self.queryLabels, ',')]),

  podLabels: (if self.showMultiCluster then self.clusterLabel + ',' else '') + 'namespace,pod',
  podSelector: std.join(',', ['%s=~"$%s"' % [label, label] for label in std.split(self.podLabels, ',')]),
  podLegend: std.join(' ', ['{{%s}}' % [label] for label in std.split(self.podLabels, ',')]),

  containerLabels: (if self.showMultiCluster then self.clusterLabel + ',' else '') + 'namespace,pod,container',
  containerSelector: std.join(',', ['%s=~"$%s"' % [label, label] for label in std.split(self.containerLabels, ',')]),
  containerLegend: std.join(' ', ['{{%s}}' % [label] for label in std.split(self.containerLabels, ',')]),

  appLabels: (if self.showMultiCluster then self.clusterLabel + ',' else '') + 'app_name,namespace',

  y: {
    kubernetesDeployments: 0,
  },
}
