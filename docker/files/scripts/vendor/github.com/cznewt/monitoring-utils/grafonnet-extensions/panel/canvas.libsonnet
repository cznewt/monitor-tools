local g = import 'g.libsonnet';

{
  local canvas = g.panel.canvas,

  base(title, targets):
    canvas.new(title)
    + canvas.queryOptions.withTargets(targets),
}
