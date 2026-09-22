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
  // Wrap a mixin's recording + alerting rule groups in a single Kubernetes
  // ConfigMap. The rules live under `data` as one Prometheus rule file
  // (`{ groups: [...] }`) so a config-reloader sidecar (e.g. kiwigrid's
  // k8s-sidecar) can drop the file into Prometheus' rule_files directory.
  // `prometheusNamespace` / `prometheusLabels` are threaded in from the
  // top-level `prometheus:` config block by cbm.libsonnet; the labels are
  // what the sidecar selects matching ConfigMaps on.
  prometheusRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'prometheusNamespace') then config.prometheusNamespace else 'default');
    local labels = (if std.objectHasAll(config, 'prometheusLabels') then config.prometheusLabels else {});
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    local groups =
      (if std.objectHasAll(rules, 'groups') then rules.groups else []) +
      (if std.objectHasAll(alerts, 'groups') then alerts.groups else []);
    if std.length(groups) == 0 then {} else {
      [config.mixinName + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: config.mixinName,
          namespace: namespace,
        } + (if std.length(labels) > 0 then { labels: labels } else {}),
        data: {
          [config.mixinName + '.yaml']: std.manifestYamlDoc(
            { groups: groups }, indent_array_in_object=true, quote_keys=false
          ),
        },
      }, indent_array_in_object=true, quote_keys=false),
    },

  // Wrap a mixin's Loki rule groups (the ones named in `lokiRuleGroups`) in a
  // Kubernetes ConfigMap, one rule file per group under `data`. Loki's ruler
  // API is read-only on the local rule store, so this is how rule groups reach
  // a Loki whose config sidecar syncs labelled ConfigMaps into the ruler's
  // directory. `lokiNamespace` / `lokiLabels` come from the top-level `loki:`
  // block; the labels are the sidecar's selector.
  lokiRuleGroups(mixin, config)::
    local selected = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else 'default');
    local labels = (if std.objectHasAll(config, 'lokiLabels') then config.lokiLabels else {});
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    local groups = [
      g
      for g in (if std.objectHasAll(rules, 'groups') then rules.groups else []) + (if std.objectHasAll(alerts, 'groups') then alerts.groups else [])
      if std.member(selected, g.name)
    ];
    if std.length(groups) == 0 then {} else {
      [config.mixinName + '-loki-rules.yaml']: std.manifestYamlDoc({
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: config.mixinName + '-loki-rules',
          namespace: namespace,
        } + (if std.length(labels) > 0 then { labels: labels } else {}),
        data: {
          [config.mixinName + '-' + group.name + '.yaml']: std.manifestYamlDoc(
            { groups: [group] }, indent_array_in_object=true, quote_keys=false
          )
          for group in groups
        },
      }, indent_array_in_object=true, quote_keys=false),
    },
}
