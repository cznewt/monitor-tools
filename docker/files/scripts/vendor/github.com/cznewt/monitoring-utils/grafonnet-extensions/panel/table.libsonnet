local g = import 'g.libsonnet';

{
  local table = g.panel.table,
  local override = table.standardOptions.override,
  local step = table.standardOptions.threshold.step,

  base(title, targets):
    table.new(title)
    + table.queryOptions.withTargets(targets),
}
