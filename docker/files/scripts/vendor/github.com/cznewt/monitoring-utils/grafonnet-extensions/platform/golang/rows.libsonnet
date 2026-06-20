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

  golangStats:
    local y = if std.objectHas(config.y, 'golangStats') then config.y.golangStats else 0;
    [
      g.ext.panel.timeSeries.base('Goroutines', queries.goroutines)
      + { gridPos: { h: 6, w: 8, x: 0, y: y } },
      g.ext.panel.timeSeries.base('Threads', queries.threads)
      + { gridPos: { h: 6, w: 8, x: 8, y: y } },
      g.ext.panel.timeSeries.seconds('GC duration', queries.gcDuration)
      + { gridPos: { h: 6, w: 8, x: 16, y: y } },
    ],

}
