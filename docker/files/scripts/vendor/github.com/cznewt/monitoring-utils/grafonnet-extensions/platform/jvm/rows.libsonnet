local g = import 'g.libsonnet';

/*
      g.tablePanel(
        {
          cluster: { alias: 'Cluster' },
          namespace: { alias: 'Namespace' },
          pod: { alias: 'Pod' },
          app_version: { alias: 'Application Version' },
          version: { alias: 'Runtime Version' },
        }
      )
 */


function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  toList(): [
    self.jvmStats,
  ],

  processStats: [
    g.ext.panel.timeSeries.memoryUsage('Memory usage', queries.processMemoryUsage)
    + { gridPos: { h: 6, w: 12, x: 0, y: 0 } },
  ],

  jvmInfo: [],

  jvmStats: [
    g.ext.panel.timeSeries.base('Threads', queries.threads)
    + { gridPos: { h: 6, w: 6, x: 0, y: 0 } },
    g.ext.panel.timeSeries.base('Loaded classes', queries.loadedClasses)
    + { gridPos: { h: 6, w: 6, x: 6, y: 0 } },
    g.ext.panel.timeSeries.seconds('GC duration', queries.gcDuration)
    + { gridPos: { h: 6, w: 6, x: 12, y: 0 } },
    g.ext.panel.timeSeries.base('GC collections', queries.gcCount)
    + { gridPos: { h: 6, w: 6, x: 18, y: 0 } },
  ],

}
