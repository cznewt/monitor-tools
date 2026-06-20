local g = import 'g.libsonnet';

function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  pythonInfo: [],

  processStats: [
    g.ext.panel.timeSeries.memoryUsage('Memory usage', queries.processMemoryUsage)
    + { gridPos: { h: 6, w: 8, x: 0, y: 0 } },
    g.ext.panel.timeSeries.base('CPU usage', queries.processCpuUsage)
    + { gridPos: { h: 6, w: 8, x: 8, y: 0 } },
    g.ext.panel.timeSeries.short('File descriptors', queries.fileDescriptors)
    + { gridPos: { h: 6, w: 8, x: 16, y: 0 } },
  ],

  pythonStats: [
    g.ext.panel.timeSeries.base('GC collections', queries.gcCollections)
    + { gridPos: { h: 6, w: 6, x: 0, y: 0 } },
    g.ext.panel.timeSeries.seconds('Collected GC objects', queries.gcCollectedObjects)
    + { gridPos: { h: 6, w: 6, x: 6, y: 0 } },
    g.ext.panel.timeSeries.base('Uncollectable GC objects', queries.gcUncoollectableObjects)
    + { gridPos: { h: 6, w: 6, x: 12, y: 0 } },
  ],

}
