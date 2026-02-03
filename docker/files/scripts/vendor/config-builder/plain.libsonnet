{
  grafanaDashboards(mixin, config)::
    {
      [name]: std.manifestJsonEx(mixin.grafanaDashboards[name], '  ')
      for name in std.objectFields(if std.objectHasAll(mixin, 'grafanaDashboards') then mixin.grafanaDashboards else {})
    },
  promRuleGroups(mixin, config)::
    local rules = (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules else { groups: [] });
    local alerts = (if std.objectHasAll(mixin, 'prometheusAlerts') then mixin.prometheusAlerts else { groups: [] });
    {
      [group.name + '.yaml']: std.manifestYamlDoc(group, indent_array_in_object=true, quote_keys=false)
      for group in rules.groups
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc(group, indent_array_in_object=true, quote_keys=false)
      for group in alerts.groups
    },
}
