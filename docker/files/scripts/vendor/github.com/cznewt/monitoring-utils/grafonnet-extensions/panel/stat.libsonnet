local g = import 'g.libsonnet';

{
  local stat = g.panel.stat,
  local override = stat.standardOptions.override,

  base(title, targets):
    stat.new(title)
    + stat.queryOptions.withTargets(targets),

  short(title, targets):
    self.base(title, targets),

  bytes(title, targets):
    self.base(title, targets),

  percent(title, targets):
    self.base(title, targets)
    + stat.standardOptions.withMin(0)
    + stat.standardOptions.withMax(100)
    + stat.standardOptions.withUnit('percent')
    + stat.standardOptions.withDecimals(1),

  percentUnit(title, targets):
    self.base(title, targets)
    + stat.standardOptions.withMin(0)
    + stat.standardOptions.withMax(1)
    + stat.standardOptions.withUnit('percentunit'),

}
