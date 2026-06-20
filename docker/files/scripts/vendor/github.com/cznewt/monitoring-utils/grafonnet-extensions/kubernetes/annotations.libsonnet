local g = import 'g.libsonnet';
local annotation = g.dashboard.annotation;

/**
      {
        "datasource": {
          "type": "prometheus",
          "uid": "${datasource}"
        },
        "enable": false,
        "expr": "metricquery",
        "iconColor": "red",
        "name": "New annotation2",
        "step": "10m",
        "tagKeys": "tag1,tag2",
        "target": {
          "limit": 100,
          "matchAny": false,
          "tags": [],
          "type": "dashboard"
        },
        "textFormat": "texts",
        "titleFormat": "annotatitiontitle",
        "useValueForTime": "on"
      }
 */

function(config, variables) {

  podStart:
    annotation.withName('Pod starts')
    + annotation.withDatasource(variables.datasource)
    + {
      expr: |||
        min(
          min_over_time(
            kube_pod_start_time{%(querySelector)s}[12h]
          )
        ) by (%(queryLabels)s) * 1000
        * on(%(queryLabels)s) group_left(node)
        max(
          up{%(querySelector)s}
        ) by (%(queryLabels)s,node)
      ||| % config,
      step: '10m',
      iconColor: 'green',
      titleFormat: if config.showMultiCluster then
        'App {{ namespace }}/{{ pod }} started at {{ node }} in {{ cluster }}.'
      else
        'App {{ namespace }}/{{ pod }} started at {{ node }}.',
      useValueForTime: 'on',
    },

  podCrash:
    annotation.withName('Pod crashes')
    + annotation.withDatasource(variables.datasource)
    + {
      expr: |||
        min(
          changes(kube_pod_container_status_restarts_total{%(querySelector)s}[10m]) > 0
        ) by (%(queryLabels)s)
        * on(%(queryLabels)s) group_left(node)
        max(
          up{%(querySelector)s}
        ) by (%(queryLabels)s,node)
      ||| % config,
      step: '10m',
      iconColor: 'red',
      titleFormat: if config.showMultiCluster then
        'App {{ namespace }}/{{ pod }} crashed at {{ node }} in {{ cluster }}.'
      else
        'App {{ namespace }}/{{ pod }} crashed at {{ node }}.',
    },

  podAlert:
    annotation.withName('Pod alerts')
    + annotation.withDatasource(variables.datasource)
    + {
      expr: |||
        min(
          changes(ALERTS{%(podSelector)s,alertstate="firing"}[10m]) > 0
        ) by (%(queryLabels)s)
      ||| % config,
      step: '10m',
      iconColor: 'yellow',
      titleFormat: if config.showMultiCluster then
        'App {{ namespace }}/{{ pod }} raised {{ alertname }} alert in {{ cluster }}.'
      else
        'App {{ namespace }}/{{ pod }} raised {{ alertname }} alert.',
    },

}
