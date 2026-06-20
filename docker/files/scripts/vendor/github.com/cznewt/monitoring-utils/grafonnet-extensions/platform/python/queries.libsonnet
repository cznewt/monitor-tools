local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;

function(config, variables) {

  processCpuUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'sum by (%(queryLabels)s) (rate(process_cpu_seconds_total{%(querySelector)s}[%(intervalVar)s]))' % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{area}}' % config),

  processMemoryUsage: [
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'process_virtual_memory_bytes{%(querySelector)s}' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s virtual' % config),
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'process_resident_memory_bytes{%(querySelector)s}' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s resident' % config),
  ],

  info:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'count by (%(queryLabels)s,app_version,version,implementation) (python_info{%(querySelector)s})' % config
    )
    + prometheusQuery.withIntervalFactor(2),

  fileDescriptors: [
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'process_open_fds{%(querySelector)s}' % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s open' % config),
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'process_max_fds{%(querySelector)s}' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s max' % config),
  ],

  gcCollections:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'sum by (%(queryLabels)s, generation) (rate(python_gc_collections_total{%(querySelector)s}[%(intervalVar)s]))' % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{generation}}' % config),

  gcCollectedObjects:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'sum by (%(queryLabels)s, generation) (rate(python_gc_objects_collected_total{%(querySelector)s}[%(intervalVar)s]))' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{generation}}' % config),

  gcUncoollectableObjects:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'sum by (%(queryLabels)s, generation) (rate(python_gc_objects_uncollectable_total{%(querySelector)s}[%(intervalVar)s]))' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{generation}}' % config),
}
