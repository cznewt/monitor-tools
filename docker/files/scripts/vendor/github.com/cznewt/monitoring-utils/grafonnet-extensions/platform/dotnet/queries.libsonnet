local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;

function(config, variables) {

  processOverview:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        count by (%(queryLabels)s,app_version,runtime_version,os_version) (dotnet_build_info{%(querySelector)s})
      ||| % config
    ),

  processMemoryUsage:

    g.ext.base.queries.prometheus.tableQuery(
      variables,
      [
        'process_virtual_memory_bytes{%(querySelector)s}' % config,
        'process_private_memory_bytes{%(querySelector)s}' % config,
      ],
      [
        '%(queryLegend)s virtual' % config,
        '%(queryLegend)s private' % config,
      ]
    ),

  processCPuUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (%(queryLabels)s) (rate(process_cpu_seconds_total{%(querySelector)s}[%(intervalVar)s]))

      ||| % config
    )
    + prometheusQuery.withLegendFormat('%(queryLegend)s' % config),

  threads:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        process_num_threads{%(querySelector)s}
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      {{cluster}} {{namespace}}
    ||| % config),

  gcDuration:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (%(queryLabels)s, generation) (
          rate(
            dotnet_gc_collection_count_total{%(querySelector)s}[%(intervalVar)s]
          )
        )
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      %(queryLegend)s {{generation}}
    ||| % config),

  gcCount:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'increase(dotnet_collection_count_total{%(querySelector)s}[%(intervalVar)s])' % config,
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      %(queryLegend)s {{generation}}
    ||| % config),
}
