local g = import 'g.libsonnet';

function(config, variables) {
  local panels = (import './panels.libsonnet')(config, variables),
  local queries = (import './queries.libsonnet')(config, variables),
  local h = config.h,

  timeSeriesStyle:
    local y = if std.objectHas(config.y, 'timeSeriesStyle') then config.y.timeSeriesStyle else 0;
    [
      g.ext.panel.text.plain(|||
        #### Graph styles

        Use this option to define how to display your time series data. You can use overrides to combine multiple styles in the same graph.

        ```
        custom = timeSeries.fieldConfig.defaults.custom

        timeSeriesBase(title, targets)
        + custom.withDrawStyle('line/bars/points')
        ```

        * Lines
        * Bars
        * Points
      |||)
      + { gridPos: { h: h, w: 6, x: 0, y: y } },
      panels.timeSeries.styleLine('Style "Line"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 6, y: y } },
      panels.timeSeries.stylePoints('Style "Points"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 12, y: y } },
      panels.timeSeries.styleBars('Style "Bars"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 18, y: y } },
    ],

  timeSeriesFillOpacity:
    local y = if std.objectHas(config.y, 'timeSeriesFillOpacity') then config.y.timeSeriesFillOpacity else 0;
    [
      g.ext.panel.text.plain(|||
        #### Fill opacity

        ```
        timeSeriesBase(title, targets)
        + custom.withFillOpacity(1-100)
        ```

        Use opacity to specify the series area fill color.
      |||)
      + { gridPos: { h: h, w: 6, x: 0, y: y } },
      panels.timeSeries.fillOpacityNone('None (0%)', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 6, y: y } },
      panels.timeSeries.fillOpacityFaint('Faint (50%)', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 12, y: y } },
      panels.timeSeries.fillOpacityFull('Full (100%)', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 18, y: y } },
    ],

  timeSeriesLineStyle:
    local y = if std.objectHas(config.y, 'timeSeriesLineStyle') then config.y.timeSeriesLineStyle else 0;
    [
      g.ext.panel.text.plain(|||
        #### Line style

        Set the style of the line.

        ```
        timeSeriesBase(title, targets)
        + custom.lineStyle.withFill('solid/dash/dots')
        ```

        * Solid: Display a solid line. This is the default setting.
        * Dash: Display a dashed line. By default dash spacing is set to 10, 10.
        * Dots: Display dotted lines. By default dot spacing is set to 0, 10.
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.timeSeries.lineStyleSolid('Style "Solid"', queries.testdataSetLines)
      + { gridPos: { h: h, w: 4, x: 8, y: y } },
      panels.timeSeries.lineStyleDash('Style "Dash"', queries.testdataSetLines)
      + { gridPos: { h: h, w: 4, x: 12, y: y } },
      panels.timeSeries.lineStyleDot('Style "Dot"', queries.testdataSetLines)
      + { gridPos: { h: h, w: 4, x: 16, y: y } },
      panels.timeSeries.lineStyleSquare('Style "Square"', queries.testdataSetLines)
      + { gridPos: { h: h, w: 4, x: 20, y: y } },
    ],

  timeSeriesLineWidth:
    local y = if std.objectHas(config.y, 'timeSeriesLineWidth') then config.y.timeSeriesLineWidth else 0;
    [
      g.ext.panel.text.plain(|||
        #### Line width

        Line width controls the thickness for series lines or the outline for bars.

        ```
        timeSeriesBase(title, targets)
        + custom.withLineWidth(1+)
        ```
      |||)
      + { gridPos: { h: h, w: 6, x: 0, y: y } },
      panels.timeSeries.lineWidth1('Width 1', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 6, y: y } },
      panels.timeSeries.lineWidth3('Width 3', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 12, y: y } },
      panels.timeSeries.lineWidth5('Width 5', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 18, y: y } },
    ],

  timeSeriesLineInterpolation:
    local y = if std.objectHas(config.y, 'timeSeriesLineInterpolation') then config.y.timeSeriesLineInterpolation else 0;
    [
      g.ext.panel.text.plain(|||
        #### Line interpolation

        This option controls how the graph interpolates the series line.

        ```
        timeSeriesBase(title, targets)
        + custom.withLineInterpolation('linear/smooth/stepBefore/stepAfter')
        ```

        * Linear: Points are joined by straight lines.
        * Smooth: Points are joined by curved lines that smooths transitions between points.
        * Step before: The line is displayed as steps between points. Points are rendered at the end of the step.
        * Step after: The line is displayed as steps between points. Points are rendered at the beginning of the step.
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.timeSeries.lineInterpolationLinear('Interpolation "Linear"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 8, y: y } },
      panels.timeSeries.lineInterpolationSmooth('Interpolation "Smooth"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 12, y: y } },
      panels.timeSeries.lineInterpolationStepBefore('Interpolation "Step before"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 16, y: y } },
      panels.timeSeries.lineInterpolationStepAfter('Interpolation "Step after"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 20, y: y } },
    ],

  timeSeriesGradientMode:
    local y = if std.objectHas(config.y, 'timeSeriesGradientMode') then config.y.timeSeriesGradientMode else 0;
    [
      g.ext.panel.text.plain(|||
        #### Gradient modes

        Gradient mode specifies the gradient fill, which is based on the series color.

        ```
        timeSeriesBase(title, targets)
        + custom.withGradientMode('none/opacity/hue/scheme')
        ```

        * None: No gradient fill.
        * Opacity: An opacity gradient where the opacity of the fill increases as y-axis values increase.
        * Hue: A subtle gradient that is based on the hue of the series color.
        * Scheme: A color gradient defined by your Color scheme.
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.timeSeries.gradientModeNone('Gradient "None"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 8, y: y } },
      panels.timeSeries.gradientModeOpacity('Gradient "Opacity"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 12, y: y } },
      panels.timeSeries.gradientModeHue('Gradient "Hue"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 16, y: y } },
      panels.timeSeries.gradientModeScheme('Gradient "Scheme"', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 4, x: 20, y: y } },
    ],

  timeSeriesMinMax:
    local y = if std.objectHas(config.y, 'timeSeriesMinMax') then config.y.timeSeriesMinMax else 0;
    [
      g.ext.panel.text.plain(|||
        #### Soft min and soft max

        By default, Grafana sets the range for the y-axis automatically based on the dataset. Hard min/max values help prevent obscuring useful detail in the data by clipping intermittent spikes past a specific point.

        ```
        + timeSeries.standardOptions.withMin/Max(10)
        ```

        Soft min/max option prevents small variations in the data from being magnified when it's mostly flat.

        ```
        + custom.withAxisSoftMin/Max(10)
        ```
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.timeSeries.minMaxAuto('Auto min/max', queries.testdataSetMaxNormal)
      + { gridPos: { h: h, w: 4, x: 8, y: y } },
      panels.timeSeries.minMaxHard('Min: 0, max: 30', queries.testdataSetMaxNormal)
      + { gridPos: { h: h, w: 4, x: 12, y: y } },
      panels.timeSeries.minMaxHard('Fixed min/max with spike', queries.testdataSetMaxSpike)
      + { gridPos: { h: h, w: 4, x: 16, y: y } },
      panels.timeSeries.minMaxSoft('Soft min/max with spike', queries.testdataSetMaxSpike)
      + { gridPos: { h: h, w: 4, x: 20, y: y } },
    ],

  timeSeriesThreshold:
    local y = if std.objectHas(config.y, 'timeSeriesThreshold') then config.y.timeSeriesThreshold else 0;
    [
      g.ext.panel.text.plain(|||
        #### Thresholds

        * You can define one or two thresholds.
        * You can have lower bound thresholds as well.

        ```
        timeSeriesBase(title, targets)
        + timeSeries.standardOptions.thresholds.withSteps([
          step.withColor('transparent') + step.withValue(null),
          step.withColor('#FF0000') + step.withValue(123),
        ])
        + custom.thresholdsStyle.withMode('line+area')
        ```
      |||)
      + { gridPos: { h: h, w: 6, x: 0, y: y } },
      panels.timeSeries.thresholdUpper('Upper threshold', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 6, y: y } },
      panels.timeSeries.thresholdLower('Lower threshold', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 12, y: y } },
      panels.timeSeries.thresholdBoth('Both thresholds', queries.testdataSetGauge)
      + { gridPos: { h: h, w: 6, x: 18, y: y } },
    ],

  timeSeriesYAxis:
    local y = if std.objectHas(config.y, 'timeSeriesYAxis') then config.y.timeSeriesYAxis else 0;
    [
      g.ext.panel.text.plain(|||
        #### Multiple Y-axes

        The new panel supports more than 2 y-axes. You control axis by setting unit. You can create new axis by setting unit using an override rule.

        ```
        timeSeriesBase(title, targets)
        + timeSeries.standardOptions.withOverrides([
          override.byName.new('Temperature')
          + override.byName.withProperty('unit', 'celsius')
          + override.byName.withProperty('custom.axisPlacement', 'right')
        ])
        ```
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.timeSeries.yAxes2('Two Y-axes', [queries.testdataSetGauge, queries.testdataSetLargeRandomGauge])
      + { gridPos: { h: h, w: 8, x: 8, y: y } },
      panels.timeSeries.yAxes3('Three Y-axes', [queries.testdataSetGauge, queries.testdataSetLargeGauge, queries.testdataSetLargeRandomGauge])
      + { gridPos: { h: h, w: 8, x: 16, y: y } },
    ],

  tableCellOptions:
    local y = if std.objectHas(config.y, 'tableCellOptions') then config.y.tableCellOptions else 0;
    [
      g.ext.panel.text.plain(|||
        #### Custom cell properties

        * Column width / Minimum column width
        * Column alignment
        * Cell type (see bellow)

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byType.new('number')
          + override.byName.withProperty('custom.width', 80),
          + override.byType.withProperty('custom.align', 'center'),
        ])
        ```

      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.table.cellOptions('Custom cell properties', queries.testdataSetTable)
      + { gridPos: { h: h, w: 16, x: 8, y: y } },
    ],

  tableCellColors:
    local y = if std.objectHas(config.y, 'tableCellColors') then config.y.tableCellColors else 0;
    [
      g.ext.panel.text.plain(|||
        #### Custom cell colors

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byType.new('number')
          + override.byName.withProperty('custom.width', 80),
          + override.byType.withProperty('custom.align', 'center'),
        ])
        ```

      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      //panels.table.cellOptions('Custom cell properties', queries.testdataSetTable)
      //+ { gridPos: { h: h, w: 16, x: 8, y: y } },
    ],

  tableImageCells:
    local y = if std.objectHas(config.y, 'tableCellTypeImage') then config.y.tableCellTypeImage else 0;
    [
      g.ext.panel.text.plain(|||
        #### Cell type image

        Field with value that is an image URL or a base64 encoded image can be displayed as an image.

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byName.new('Image')
          + override.byName.withProperty('custom.cellOptions', {
            type: 'image',
          }),
        ])
        ```

      |||)
      + { gridPos: { h: 12, w: 8, x: 0, y: y } },
      panels.table.cellOptions('Image cell', queries.testdataSetTable)
      + { gridPos: { h: 12, w: 16, x: 8, y: y } },
    ],

  tableCellTypeImage:
    local y = if std.objectHas(config.y, 'tableCellTypeImage') then config.y.tableCellTypeImage else 0;
    [
      g.ext.panel.text.plain(|||
        #### Cell type image

        Field with value that is an image URL or a base64 encoded image can be displayed as an image.

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byName.new('Image')
          + override.byName.withProperty('custom.cellOptions', {
            type: 'image',
          }),
        ])
        ```

      |||)
      + { gridPos: { h: 12, w: 8, x: 0, y: y } },
      panels.table.cellOptions('Image cell', queries.testdataSetTable)
      + { gridPos: { h: 12, w: 16, x: 8, y: y } },
    ],


  tableCellGaugeBars:
    local y = if std.objectHas(config.y, 'tableCellGaugeBars') then config.y.tableCellGaugeBars else 0;
    [
      g.ext.panel.text.plain(|||
        #### Gell type gauge

        Cells can be displayed as a graphical gauge, with several different presentation types.

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byName.new('Sensor')
          + override.byName.withProperty('custom.cellOptions', {
            mode: 'basic/gradient/lcd',
            type: 'gauge',
          }),
        ])
        ```

      |||)
      + { gridPos: { h: h, w: 6, x: 0, y: y } },
      panels.table.cellTypeGaugeBarBasic('Basic gauge cell', queries.testdataSetSmallTable)
      + { gridPos: { h: h, w: 6, x: 6, y: y } },
      panels.table.cellTypeGaugeBarGradient('Gradient gauge cell', queries.testdataSetSmallTable)
      + { gridPos: { h: h, w: 6, x: 12, y: y } },
      panels.table.cellTypeGaugeBarLcd('LCD gauge cell', queries.testdataSetSmallTable)
      + { gridPos: { h: h, w: 6, x: 18, y: y } },
    ],

  tableCellSparklines:
    local y = if std.objectHas(config.y, 'tableCellSparklines') then config.y.tableCellSparklines else 0;
    [
      g.ext.panel.text.plain(|||
        #### Cell type sparklines

        Shows value rendered as a sparkline. Requires time series to table data transform.

        ```
        tableBase(title, targets)
        + table.standardOptions.withOverrides([
          override.byName.new('Sensor')
          + override.byName.withProperty('custom.cellOptions', {
            type: 'sparkline',
          }),
        ])
        ```

      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.table.cellTypeSparkline('Sparkline cell', queries.prometheusSmallTableValues)
      + { gridPos: { h: h, w: 16, x: 8, y: y } },
    ],


  alertListBasic:
    local y = if std.objectHas(config.y, 'alertListBasic') then config.y.alertListBasic else 0;
    [
      g.ext.panel.text.plain(|||
        #### Alert lists

        Use alert lists to display your alerts. You can configure the list to show the current state.
      |||)
      + { gridPos: { h: h, w: 8, x: 0, y: y } },
      panels.alertList.criticalAlerts('Critical alerts', '{severity="critical"}')
      + { gridPos: { h: h, w: 8, x: 8, y: y } },
      panels.alertList.allAlerts('All alerts', '{alertname=~".+"}')
      + { gridPos: { h: h, w: 8, x: 16, y: y } },
    ],

  canvasHomeSolarDay:
    local y = if std.objectHas(config.y, 'canvasHomeSolarDay') then config.y.canvasHomeSolarDay else 0;
    [
      g.ext.panel.text.plain(|||
        #### Home Solar Energy Demo (Day)

        This demo show cases an example off grid home solar system with batteries. In this example we set a background animated gif to represent our home solar system. We then overlayed metric values to represent the solar output, battery charging rate, and house energy drain.
      |||)
      + { gridPos: { h: h * 2, w: 8, x: 0, y: y } },
      panels.canvas.homeSolarDay('', queries.testdataHomeSolarDay)
      + { gridPos: { h: h * 2, w: 14, x: 10, y: y } },
    ],

}

