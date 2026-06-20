local g = import 'g.libsonnet';

{
  local logs = g.panel.logs,

  base(title, targets):
    logs.new(title)
    + logs.queryOptions.withTargets(targets),
}
