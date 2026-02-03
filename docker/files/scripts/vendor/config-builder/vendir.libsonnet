{
  vendirMixinConfig(config)::
    {
      [if std.objectHas(config.mixins[name], 'source') then 'vendir.' + name + '-mixin.yaml']: std.manifestYamlDoc({
        apiVersion: 'vendir.k14s.io/v1alpha1',
        kind: 'Config',
        directories: [{
          path: 'mixins/' + name + '-mixin',
          contents: [{
            path: '.'
          } + config.mixins[name].source],
        }],
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(config.mixins)
    },
  vendirLibConfig(config)::
    {
      [if std.objectHas(config.mixins[name], 'source') then 'vendir.' + name + '-lib.yaml']: std.manifestYamlDoc({
        apiVersion: 'vendir.k14s.io/v1alpha1',
        kind: 'Config',
        directories: [{
          path: 'vendor/' + name,
          contents: [{
            path: '.'
          } + config.libs[name].source],
        }],
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(if std.objectHas(config, 'libs') then config.libs else {})
    },
}
