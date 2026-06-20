local g = import 'g.libsonnet';

{
  local heatmap = g.panel.heatmap,
  local options = heatmap.options,

  base(title, targets):
    heatmap.new(title)
    + heatmap.queryOptions.withTargets(targets)
    + heatmap.queryOptions.withInterval('1m')
    + options.withCalculate()
    + options.calculation.xBuckets.withMode('size')
    + options.calculation.xBuckets.withValue('1min')
    + options.withCellGap(2)
    + options.color.HeatmapColorOptions.withMode('scheme')
    + options.color.HeatmapColorOptions.withScheme('Spectral')
    + options.color.HeatmapColorOptions.withSteps(128)
    + options.yAxis.withDecimals(0)
    + options.yAxis.withUnit('s'),
}
