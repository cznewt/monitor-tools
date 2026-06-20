local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local lokiQuery = g.query.loki;

{
  prometheus: {

    listQuery(variables, queries, legends=null)::
      std.mapWithIndex(function(i, query)
        (g.query.prometheus.new(
           '$' + variables.datasource.name,
           query,
         ) + if legends != null then
           g.query.prometheus.withLegendFormat(legends[i])
         else {}), queries),

    tableQuery(variables, queries, legends=null)::
      std.mapWithIndex(function(i, query)
        (g.query.prometheus.new(
           '$' + variables.datasource.name,
           query,
         ) + g.query.prometheus.withInstant(true)
         + g.query.prometheus.withRange(false)
         + g.query.prometheus.withFormat('table')
         + if legends != null then
           g.query.prometheus.withLegendFormat(legends[i])
         else {}), queries),

  },

}
