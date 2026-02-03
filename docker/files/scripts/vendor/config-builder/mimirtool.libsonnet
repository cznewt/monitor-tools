{
  alertmanagerConfig(config)::
    {
      ['alertmanager.yml']: std.manifestYamlDoc(config.alertmanager.config, indent_array_in_object=true, quote_keys=false)
    } +
    {
      [name]: config.alertmanager.templates[name]
      for name in std.objectFields(config.alertmanager.templates)
    },
  promAlertRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
    },
  promRecordRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
    },
  promRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
    },
}
