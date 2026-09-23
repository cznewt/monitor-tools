{
  // A mixin is a few jsonnet files in a subdirectory; the repository's own
  // submodules are never part of it. vendir clones with submodules by default,
  // and one that has gone away (Loki's website theme, for instance) fails the
  // whole sync - so skip them unless a source asks for them.
  local source(spec) =
    if std.objectHas(spec, 'git') then spec { git: { skipInitSubmodules: true } + spec.git } else spec,

  vendirMixinConfig(config)::
    {
      [if std.objectHas(config.mixins[name], 'source') then 'vendir.' + name + '-mixin.yaml']: std.manifestYamlDoc({
        apiVersion: 'vendir.k14s.io/v1alpha1',
        kind: 'Config',
        directories: [{
          path: 'mixins/' + name + '-mixin',
          contents: [{
            path: '.'
          } + source(config.mixins[name].source)],
        }],
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(config.mixins)
    },
  vendirLibConfig(config)::
    {
      [if std.objectHas(config.libs[name], 'source') then 'vendir.' + name + '-lib.yaml']: std.manifestYamlDoc({
        apiVersion: 'vendir.k14s.io/v1alpha1',
        kind: 'Config',
        directories: [{
          path: 'mixins/' + name,
          contents: [{
            path: '.'
          } + source(config.libs[name].source)],
        }],
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(if std.objectHas(config, 'libs') then config.libs else {})
    },
}
