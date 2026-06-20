{

  showMultiCluster: true,

  clusterLabel: 'cluster',
  clusterVariableSelector: 'cluster=~".+"',
  clusterSelector: '%(clusterLabel)s=~"$cluster"' % self,

  namespaceLabel: 'namespace',
  namespaceSelector: '%(clusterLabel)s=~"$cluster",node=~"$node"' % self,

  nodeLabel: 'node',
  nodeSelector: '%(clusterLabel)s=~"$cluster",node=~"$node"' % self,

  appLabel: 'app_name',
  appPartOfLabel: 'app_part_of',

  runbooksAlertDatasource: 'prometheus',

  // Default datasource name
  datasourceName: 'default',

  // Datasource instance filter regex
  datasourceFilterRegex: '',

  // For links between grafana dashboards, you need to tell us if your grafana
  // servers under some non-root path.
  linkPrefix: '',

  // The default refresh time for all dashboards, default to 10s
  refresh: '10m',
  minimumTimeInterval: '1m',

  intervalVar: '5m',
  rateInterval: '5m',

  // scrapeIntervalSeconds is the global scrape interval which can be
  // used to dynamically adjust rate windows as a function of the interval.
  scrapeInterval: 30,
  // Dashboard variable refresh option on Grafana (https://grafana.com/docs/grafana/latest/datasources/prometheus/).
  // 0 : Never (Will never refresh the Dashboard variables values)
  // 1 : On Dashboard Load  (Will refresh Dashboards variables when dashboard are loaded)
  // 2 : On Time Range Change (Will refresh Dashboards variables when time range will be changed)
  dashboardRefresh: 2,

  // Timezone for Grafana dashboards:: UTC, browser, ...
  grafanaTimezone: 'UTC',

  tags: [],

  alertmanagerAlertsEnabled: true,
  lokiLogsEnabled: true,
  elasticsearchLogsEnabled: false,

  kubernetesDashboardsEnabled: false,
  systemdDashboardsEnabled: false,
  windowsDashboardsEnabled: false,

}
