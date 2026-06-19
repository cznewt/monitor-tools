
local mixin = (import 'config.libsonnet') + (import '../mixin.libsonnet');

{
  [group.name + '.yaml']: std.manifestYamlDoc(group, quote_keys=false)
  for group in mixin.prometheusRules.groups
}
