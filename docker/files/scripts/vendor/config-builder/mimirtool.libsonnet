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
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    // optional separate namespace for alert groups (mimirAlertNamespace), e.g.
    // kubernetes-mixin + kubernetes-mixin-alerts, the layout mimirtool users
    // commonly load upstream mixins in.
    local alertNamespace = (if std.objectHasAll(config, 'mimirAlertNamespace') then config.mimirAlertNamespace else namespace);
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [alertNamespace + '-' + group.name + '.yaml']: std.manifestYamlDoc({
        namespace: alertNamespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
      if !std.member(lokiRuleGroups, group.name)
    },
  promRecordRuleGroups(mixin, config)::
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    {
      [namespace + '-' + group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
      if !std.member(lokiRuleGroups, group.name)
    },
  promRuleGroups(mixin, config)::
    local lokiRuleGroups = (if std.objectHasAll(config, 'lokiRuleGroups') then config.lokiRuleGroups else []);
    local namespace = (if std.objectHasAll(config, 'mimirNamespace') then config.mimirNamespace else config.mixinName);
    local alertNamespace = (if std.objectHasAll(config, 'mimirAlertNamespace') then config.mimirAlertNamespace else namespace);
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [alertNamespace + '-' + group.name + '.yaml']: std.manifestYamlDoc({
        namespace: alertNamespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
      if !std.member(lokiRuleGroups, group.name)
    } +
    {
      [namespace + '-' + group.name + '.yaml']: std.manifestYamlDoc({
        namespace: namespace,
        groups: [
          group,
        ],
      }, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
      if !std.member(lokiRuleGroups, group.name)
    },
}
