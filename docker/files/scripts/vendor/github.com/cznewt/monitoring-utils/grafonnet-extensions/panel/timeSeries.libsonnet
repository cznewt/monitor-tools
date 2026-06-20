local g = import 'g.libsonnet';

{
  local timeSeries = g.panel.timeSeries,
  local fieldOverride = g.panel.timeSeries.fieldOverride,
  local custom = timeSeries.fieldConfig.defaults.custom,
  local defaults = timeSeries.fieldConfig.defaults,
  local options = timeSeries.options,
  local override = timeSeries.standardOptions.override,

  base(title, targets):
    timeSeries.new(title)
    + timeSeries.queryOptions.withTargets(targets)
    + timeSeries.queryOptions.withInterval('1m')
    + custom.withLineWidth(2)
    + custom.withFillOpacity(0)
    + custom.withShowPoints('never'),

  short(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('short')
    + timeSeries.standardOptions.withDecimals(0),

  percentUnit(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withMin(0)
    + timeSeries.standardOptions.withMax(1)
    + timeSeries.standardOptions.withUnit('percentunit')
    + timeSeries.standardOptions.withDecimals(2),

  percent(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withMin(0)
    + timeSeries.standardOptions.withMax(100)
    + timeSeries.standardOptions.withUnit('percent')
    + timeSeries.standardOptions.withDecimals(1),

  bytes(title, targets):
    self.base(title, targets,)
    + timeSeries.standardOptions.withUnit('bytes'),
  //+ custom.scaleDistribution.withType('log')
  //+ custom.scaleDistribution.withLog(2),

  seconds(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('s')
    + custom.scaleDistribution.withType('log')
    + custom.scaleDistribution.withLog(10),

  miliseconds(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('ms')
    + custom.scaleDistribution.withType('log')
    + custom.scaleDistribution.withLog(10),

  bytesPerSecond(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('Bps'),

  requestsPerSecond(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('rps'),

  operationsPerSecond(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('ops'),

  durationQuantile(title, targets):
    self.base(title, targets)
    + timeSeries.standardOptions.withUnit('s')
    + custom.withDrawStyle('bars')
    + timeSeries.standardOptions.withOverrides([
      fieldOverride.byRegexp.new('/mean/i')
      + fieldOverride.byRegexp.withProperty(
        'custom.fillOpacity',
        0
      )
      + fieldOverride.byRegexp.withProperty(
        'custom.lineStyle',
        {
          dash: [8, 10],
          fill: 'dash',
        }
      ),
    ]),

}
