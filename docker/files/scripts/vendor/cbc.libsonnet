local builder = (import 'cb.libsonnet');

{
  vendirMixinConfig(config)::
    builder.vendir.vendirMixinConfig(config),
  vendirLibConfig(config)::
    builder.vendir.vendirLibConfig(config),
}
