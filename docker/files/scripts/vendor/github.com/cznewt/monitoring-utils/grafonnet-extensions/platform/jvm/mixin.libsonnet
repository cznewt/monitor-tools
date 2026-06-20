{
  config: (import './config.libsonnet'),
  rows: (import './rows.libsonnet')(config, variables),
}
