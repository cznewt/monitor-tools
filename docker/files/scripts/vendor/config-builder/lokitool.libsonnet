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
      for group in alerts.groups
      if std.member(lokiRuleGroups, group.name)
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
      for group in rules.groups
      if std.member(lokiRuleGroups, group.name)
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
      for group in alerts.groups
      if std.member(lokiRuleGroups, group.name)
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
      if std.member(lokiRuleGroups, group.name)
    },
}
