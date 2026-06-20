local g = import 'g.libsonnet';

function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  processStats:
    local y = if std.objectHas(config.y, 'processStats') then config.y.processStats else 0;
    [
      g.ext.panel.timeSeries.cpuUsage('CPU usage', queries.processCpuUsage)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.timeSeries.memoryUsage('Memory usage', queries.processMemoryUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

  dotnetStats:
    local y = if std.objectHas(config.y, 'dotnetStats') then config.y.dotnetStats else 0;
    [
      g.ext.panel.timeSeries.base('Threads', queries.threads)
      + { gridPos: { h: 6, w: 8, x: 0, y: y } },
      g.ext.panel.timeSeries.seconds('GC duration', queries.gcDuration)
      + { gridPos: { h: 6, w: 8, x: 8, y: y } },
      g.ext.panel.timeSeries.seconds('GC collections', queries.gcCount)
      + { gridPos: { h: 6, w: 8, x: 16, y: y } },

    ],

}

/*
local g = import 'github.com/cznewt/mixin-utils/grafana.libsonnet';

{
  dotnetOverviewRow(config)::
    g.row('Runtime Overview')
    .addPanel(
      g.panel('Service Status') +
      g.tablePanel(
        [
          '' % config,
        ], {
          cluster: { alias: 'Cluster' },
          namespace: { alias: 'Namespace' },
          pod: { alias: 'Pod' },
          name: { alias: 'Server' },
          app_version: { alias: 'Application Version' },
          runtime_version: { alias: 'Runtime Version' },
          os_version: { alias: 'OS Version' },
        }
      )
    ),

  dotnetHttpRequestsRow(config)::
    g.row('HTTP Requests')
    .addPanel(
      g.panel('HTTP Request Latency by Handler') +
      g.queryPanel(
        [
          'histogram_quantile(0.5, sum(rate(http_request_duration_seconds_bucket[%(intervalVar)s])) by (%(queryLabels)s,controller,le))' % config,
          'histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[%(intervalVar)s])) by (%(queryLabels)s,controller,le))' % config,
          'histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[%(intervalVar)s])) by (%(queryLabels)s,controller,le))' % config,
        ],
        [
          '%(queryLegend)s {{job}} {{controller}} p50' % config,
          '%(queryLegend)s {{job}} {{controller}} p95' % config,
          '%(queryLegend)s {{job}} {{controller}} p99' % config,
        ]
      ) + { yaxes: g.yaxes('s'), repeat: 'controller' }
    )
    .addPanel(
      g.panel('HTTP Requests Status by Handler') +
      g.queryPanel(
        'sum(rate(http_request_duration_seconds_bucket[%(intervalVar)s])) by (%(queryLabels)s,controller,status)' % config,
        '%(queryLegend)s {{controller}} {{status}}' % config
      ) + { yaxes: g.yaxes('ops'), repeat: 'controller' }
    ),

}
*/
