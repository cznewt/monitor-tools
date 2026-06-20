local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local elasticsearchQuery = g.query.elasticsearch;

function(config, variables) {
  local panels = (import './panels.libsonnet')(config, variables),
  local queries = (import './queries.libsonnet')(config, variables),

  local timeSeries = g.panel.timeSeries,
  local custom = timeSeries.fieldConfig.defaults.custom,
  local options = timeSeries.options,
  local color = timeSeries.standardOptions.color,
  local step = timeSeries.standardOptions.threshold.step,
  local override = timeSeries.standardOptions.override,

  alertRunbook(alert): [
    g.ext.panel.text.base('', alert.runbook)
    + g.panel.text.panelOptions.withTransparent(true)
    + { gridPos: { h: 16, w: 10, x: 0, y: 0 * 16 } },
    g.ext.panel.timeSeries.base(
      'Alert query exploration',
      prometheusQuery.new(
        '$' + variables.datasource.name,
        'topk(20, ' + alert.explore + ')',
      ),
    )
    + timeSeries.options.legend.withShowLegend(false)
    + timeSeries.standardOptions.withMin(0)
    + timeSeries.standardOptions.withMax(1)
    + (if std.objectHas(alert, 'thresholds') then
         (timeSeries.standardOptions.thresholds.withSteps([
            (step.withColor(threshold.color) + step.withValue(threshold.value))
            for threshold in alert.thresholds
          ])
          + custom.thresholdsStyle.withMode('area')) else {})
    + { gridPos: { h: 16, w: 7, x: 10, y: 0 * 16 } },
    g.ext.panel.timeSeries.base(
      'Alert series',
      prometheusQuery.new(
        '$' + variables.datasource.name,
        'count(' + alert.explore + ') by (%(clusterLabel)s)' % config,
      )
      + prometheusQuery.withLegendFormat('{{%(clusterLabel)s}}' % config)
    )
    + { gridPos: { h: 8, w: 7, x: 17, y: 0 * 16 } },
    g.ext.panel.timeSeries.base(
      'Alert occurences',
      if config.runbooksAlertDatasource == 'prometheus' then
        prometheusQuery.new(
          '$' + variables.datasource.name,
          'sum(ALERTS{alertstate="firing",alertname="' + alert.alertname + '"}) by (%(clusterLabel)s)' % config,
        )
        + prometheusQuery.withLegendFormat('{{%(clusterLabel)s}}' % config)
      else
        elasticsearchQuery.withDatasource('$' + variables.es_datasource.name)
        + elasticsearchQuery.withQuery('commonLabels.alertname:"' + alert.alertname + '"')
        + elasticsearchQuery.withTimeField('@timestamp')
        + elasticsearchQuery.withMetrics([
          { field: 'commonLabels.site', id: '1', type: 'count' },
        ])
        + elasticsearchQuery.withBucketAggs([
          {
            fake: true,
            id: '3',
            field: 'commonLabels.site',
            type: 'terms',
            settings: { min_doc_count: 1, order: 'desc', orderBy: '_count', size: '15' },
          },
          {
            id: '2',
            field: 'time',
            type: 'date_histogram',
            settings: { interval: '10m', min_doc_count: 0, trimEdges: 0 },
          },
        ])
    )
    + { gridPos: { h: 8, w: 7, x: 17, y: (0 * 16) + 8 } },
  ],

  alertRunbooks:
    std.flattenArrays(
      std.mapWithIndex(
        function(i, alert) [
          g.ext.panel.text.base('', alert.runbook)
          + g.panel.text.panelOptions.withTransparent(true)
          + { gridPos: { h: 16, w: 10, x: 0, y: i * 16 } },
          g.ext.panel.timeSeries.base(
            'Alert query exploration',
            prometheusQuery.new(
              '$' + variables.datasource.name,
              'topk(20, ' + alert.explore + ')',
            ),
          )
          + timeSeries.options.legend.withShowLegend(false)
          + timeSeries.standardOptions.withMin(0)
          + timeSeries.standardOptions.withMax(1)
          + (if std.objectHas(alert, 'thresholds') then
               (timeSeries.standardOptions.thresholds.withSteps([
                  (step.withColor(threshold.color) + step.withValue(threshold.value))
                  for threshold in alert.thresholds
                ])
                + custom.thresholdsStyle.withMode('area')) else {})
          + { gridPos: { h: 16, w: 7, x: 10, y: i * 16 } },
          g.ext.panel.timeSeries.base(
            'Alert series',
            prometheusQuery.new(
              '$' + variables.datasource.name,
              'count(' + alert.explore + ') by (%(clusterLabel)s)' % config,
            )
            + prometheusQuery.withLegendFormat('{{%(clusterLabel)s}}' % config)
          )
          + { gridPos: { h: 8, w: 7, x: 17, y: i * 16 } },
          g.ext.panel.timeSeries.base(
            'Alert occurences',
            if config.runbooksAlertDatasource == 'prometheus' then
              prometheusQuery.new(
                '$' + variables.datasource.name,
                'sum(ALERTS{alertstate="firing",alertname="' + alert.alertname + '"}) by (%(clusterLabel)s)' % config,
              )
              + prometheusQuery.withLegendFormat('{{%(clusterLabel)s}}' % config)
            else
              elasticsearchQuery.withDatasource('$' + variables.es_datasource.name)
              + elasticsearchQuery.withQuery('commonLabels.alertname:"' + alert.alertname + '"')
              + elasticsearchQuery.withTimeField('@timestamp')
              + elasticsearchQuery.withMetrics([
                { field: 'commonLabels.site', id: '1', type: 'count' },
              ])
              + elasticsearchQuery.withBucketAggs([
                {
                  fake: true,
                  id: '3',
                  field: 'commonLabels.site',
                  type: 'terms',
                  settings: { min_doc_count: 1, order: 'desc', orderBy: '_count', size: '15' },
                },
                {
                  id: '2',
                  field: 'time',
                  type: 'date_histogram',
                  settings: { interval: '10m', min_doc_count: 0, trimEdges: 0 },
                },
              ])
          )
          + { gridPos: { h: 8, w: 7, x: 17, y: (i * 16) + 8 } },
        ],
        config.runbooks
      )
    ),

}
