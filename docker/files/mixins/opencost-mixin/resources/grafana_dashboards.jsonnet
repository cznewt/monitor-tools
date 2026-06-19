
local mixin = (import 'config.libsonnet') + (import '../mixin.libsonnet');

{
  [name]: std.manifestJsonEx(mixin.grafanaDashboards[name], '  ')
  for name in std.objectFields(mixin.grafanaDashboards)
}
