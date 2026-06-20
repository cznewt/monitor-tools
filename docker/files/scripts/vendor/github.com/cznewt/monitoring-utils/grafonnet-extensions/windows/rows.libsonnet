local g = import 'g.libsonnet';

function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  windowsServiceResources:
    local y = if std.objectHas(config.y, 'windowsServiceResource') then config.y.windowsServiceResource else 0;
    [
      g.ext.panel.timeSeries.bytes('Memory usage', queries.windowsServiceMemoryUsage)
      + { gridPos: { h: 6, w: 12, x: 0, y: y } },
      g.ext.panel.timeSeries.base('CPU usage', queries.windowsServiceCpuUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
      g.ext.panel.timeSeries.bytesPerSecond('I/O usage', queries.windowsServiceIoUsage)
      + { gridPos: { h: 6, w: 12, x: 12, y: y } },
    ],

}
