{
  slothRules(config)::
    {
      [name + '.yaml']: std.manifestYamlDoc(config.sloth.slos[name], indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(config.sloth.slos)
    },
}
