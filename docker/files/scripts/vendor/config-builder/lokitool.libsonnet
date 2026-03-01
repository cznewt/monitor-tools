{
  lokiAlertRuleGroups(mixin, config)::
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      if group.name in lokiRuleGroups
      for group in alerts.groups
    },
  lokiRecordRuleGroups(mixin, config)::
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      if group.name in lokiRuleGroups
      for group in rules.groups
    },
  lokiRuleGroups(mixin, config)::
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      if group.name in lokiRuleGroups
      for group in alerts.groups
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      if group.name in lokiRuleGroups
      for group in rules.groups
    },
}
