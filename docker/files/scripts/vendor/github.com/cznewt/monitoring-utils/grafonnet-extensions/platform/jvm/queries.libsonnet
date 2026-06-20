local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;

function(config, variables) {

  processMemoryUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        jvm_memory_bytes_used{%(querySelector)s}
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{area}}' % config),

  info:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'count by (%(queryLabels)s,app_version,version,implementation) (jvm_info{%(querySelector)s})' % config
    )
    + prometheusQuery.withIntervalFactor(2),

  threads:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'jvm_threads_current{%(querySelector)s}' % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s' % config),

  loadedClasses:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'jvm_classes_loaded{%(querySelector)s}' % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s' % config),

  gcDuration:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(jvm_gc_collection_seconds_sum{%(querySelector)s}[$__rate_interval])' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{gc}}' % config),

  gcCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'jvm_gc_collection_seconds_count{%(querySelector)s}' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat('%(queryLegend)s {{gc}}' % config),

}
