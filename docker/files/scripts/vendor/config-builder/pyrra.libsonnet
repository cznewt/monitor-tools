{
  pyrraRules(config)::
    {
      [name + '.yaml']: std.manifestYamlDoc(config.pyrra.slos[name], indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(config.pyrra.slos)
    },
}
