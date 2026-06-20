local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;

function(config, variables) {

  processCpuUsage:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (cluster, namespace, pod) (
            rate(
                process_cpu_seconds_total{
                    %(clusterLabel)s=~"$cluster",
                    %(namespaceLabel)s=~"$namespace",
                    pod=~"$pod"
                }
            [$__rate_interval])
        )
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      {{cluster}} {{namespace}}
    ||| % config),

  processMemoryUsage:
    [
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          sum by (cluster, namespace, job) (
            process_virtual_memory_bytes{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
          )
        ||| % config
      )
      + prometheusQuery.withIntervalFactor(2)
      + prometheusQuery.withLegendFormat(|||
        virtual - {{cluster}} {{namespace}}
      ||| % config),
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          sum by (cluster, namespace, job) (
            process_resident_memory_bytes{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
          )
        ||| % config
      )
      + prometheusQuery.withIntervalFactor(2)
      + prometheusQuery.withLegendFormat(|||
        resident - {{cluster}} {{namespace}}
      ||| % config),
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          sum by (cluster, namespace, job) (
            go_memstats_heap_inuse_bytes{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
          )
        ||| % config
      )
      + prometheusQuery.withIntervalFactor(2)
      + prometheusQuery.withLegendFormat(|||
        go heap - {{cluster}} {{namespace}}
      ||| % config),
      prometheusQuery.new(
        '$' + variables.datasource.name,
        |||
          sum by (cluster, namespace, job) (
            go_memstats_stack_inuse_bytes{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
          )
        ||| % config
      )
      + prometheusQuery.withIntervalFactor(2)
      + prometheusQuery.withLegendFormat(|||
        go stack - {{cluster}} {{namespace}}
      ||| % config),
    ],

  goroutines:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (cluster, namespace, job) (
          go_goroutines{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
        )
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      {{cluster}} {{namespace}}
    ||| % config),

  threads:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum by (cluster, namespace, job) (
          go_threads{cluster=~"$cluster", namespace=~"$namespace", pod=~"$pod"}
        )
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
        sum by (cluster, namespace, job) (
          rate(
            go_gc_duration_seconds_sum{
                cluster=~"$cluster",
                namespace=~"$namespace",
                pod=~"$pod"
            }
          [$__rate_interval])
        )
      ||| % config
    )
    + prometheusQuery.withIntervalFactor(2)
    + prometheusQuery.withLegendFormat(|||
      {{cluster}} {{namespace}}
    ||| % config),

}
