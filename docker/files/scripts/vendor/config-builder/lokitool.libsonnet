{
  lokiAlertRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local alerts = (if std.objectHasAll(mixin, 'lokiAlerts') then mixin.lokiAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
    },
  lokiRecordRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'lokiRules') then mixin.lokiRules else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
    },
  lokiRuleGroups(mixin, config)::
    local namespace = (if std.objectHasAll(config, 'lokiNamespace') then config.lokiNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'lokiRules') then mixin.lokiRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'lokiAlerts') then mixin.lokiAlerts else { groups: [] });
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
