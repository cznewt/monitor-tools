{
  grafanaDashboards(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'grafanaNamespace') then config.grafanaNamespace else 'default');
    {
      [if std.endsWith(name, '.json') then std.strReplace(name, '.json', '.yaml') else name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: std.strReplace(name, '.json', ''),
          namespace: namespace,
        },
        data: {
          [if std.endsWith(name, '.json') then name else name + '.json']: mixin.grafanaDashboards[name],
        }
      })
      for name in std.objectFields(mixin.grafanaDashboards)
    },
  prometheusRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else 'default');
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: group.name,
          namespace: namespace,
        },
        spec: {
          rules: group.rules,
        },
      })
      for group in mixin.prometheusRules.groups
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: group.name,
          namespace: namespace,
        },
        spec: {
          rules: group.rules,
        },
      })
      for group in mixin.prometheusAlerts.groups
    },
}
