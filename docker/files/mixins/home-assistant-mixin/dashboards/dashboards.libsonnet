local g = import 'g.libsonnet';

{
  grafanaDashboards+:: {
    local config = g.ext.base.config + $._config,
    local dashboards = g.ext.base.dashboards(config),
    local variables = (import './variables.libsonnet')(config)
                      + g.ext.base.variables.env(config),
    local rows = (import './rows.libsonnet')(config, variables),

    referenceLinks(grafonnet, grafana=null)::
      local _grafana = if grafana == null then grafonnet else grafana;
      g.dashboard.withLinks([
        g.dashboard.link.link.new('Grafonnet API', 'https://grafana.github.io/grafonnet/API/panel/' + grafonnet + '/index.html')
        + g.dashboard.link.link.options.withTargetBlank(true),
        g.dashboard.link.link.new('Grafana docs', 'https://grafana.com/docs/grafana/latest/panels-visualizations/visualizations/' + _grafana + '/')
        + g.dashboard.link.link.options.withTargetBlank(true),
        g.dashboard.link.dashboards.new('Reference', 'reference'),
      ]),

    'home-assistant-alert-list.json':
      dashboards.base('Panel / Alert list', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('alertList', 'alert-list')
      + g.dashboard.withPanels(
        rows.alertListBasic
      ),

    'home-assistant-canvas.json':
      dashboards.base('Panel / Canvas', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('canvas', 'canvas')
      + g.dashboard.withPanels(
        rows.canvasHomeSolarDay
      ),

    'home-assistant-pie-chart.json':
      dashboards.base('Panel / Pie chart', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('pieChart', 'pie-chart')
      + g.dashboard.withPanels(
        []
      ),

    'home-assistant-state-history.json':
      dashboards.base('Panel / State history', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('stateHistory', 'state-history')
      + g.dashboard.withPanels(
        []
      ),

    'home-assistant-table.json':
      dashboards.base('Panel / Table', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('table')
      + g.dashboard.withVariables([
        variables.datasource,
      ])
      + g.dashboard.withPanels(
        rows.tableCellOptions
        + rows.tableCellGaugeBars
        + rows.tableCellSparklines
        + rows.tableCellColors
        + rows.tableImageCells
      ),

    'home-assistant-time-series.json':
      dashboards.base('Panel / Time series', tags=['home-assistant', 'home-assistant-panel'])
      + self.referenceLinks('timeSeries', 'time-series')
      + g.dashboard.withPanels(
        rows.timeSeriesStyle
        + rows.timeSeriesLineInterpolation
        + rows.timeSeriesFillOpacity
        + rows.timeSeriesLineStyle
        + rows.timeSeriesLineWidth
        + rows.timeSeriesGradientMode
        + rows.timeSeriesThreshold
        + rows.timeSeriesMinMax
        + rows.timeSeriesYAxis
      ),

  },
}
