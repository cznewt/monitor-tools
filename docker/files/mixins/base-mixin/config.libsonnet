local g = import 'g.libsonnet';

{
  _config+:: g.ext.base.config {

    linuxEnabled: true,
    windowsEnabled: false,

    // label hierarchy of the Base boards (dashboards/hierarchy.libsonnet)
    envLabel: 'env',
    systemLabel: self.appPartOfLabel,
    baseLevels: {
      env: { label: $._config.envLabel, title: 'Environment', onNodes: true },
      cluster: { label: $._config.clusterLabel, title: 'Cluster', onNodes: true },
      system: { label: $._config.systemLabel, title: 'System', onNodes: false },
    },
    baseSetups: {
      'env-cluster-system': {
        hierarchy: ['env', 'cluster', 'system'],
        home: { file: 'base-home', uid: 'home', title: 'Base / Home', tags: ['env-level'] },
        detail: { file: 'base-cluster', uid: 'cluster', title: 'Base / Cluster', tags: ['cluster-level'] },
      },
      'system-env': {
        hierarchy: ['system', 'env'],
        home: { file: 'base-systems', uid: 'base-systems', title: 'Base / Systems', tags: ['system-level'] },
        detail: { file: 'base-system', uid: 'base-system', title: 'Base / System', tags: ['system-level'] },
      },
    },
    // drill-down targets of the server tables (configs override them)
    serverLinuxLink: '/d/dashboardlink',
    baseClusterLink: '/d/dashboardlink',

    // one setup name or a list of them
    baseSetup: ['env-cluster-system'],

    linuxQuerySelector: '%(clusterVariableSelector)s, %(clusterLabel)s=~"$cluster"' % $._config,
    windowsQuerySelector: '%(clusterVariableSelector)s, %(clusterLabel)s=~"$cluster"' % $._config,

    y+: {
      homeDashboards: 0,
      homeResources: 12,
      linuxServers: 0,
      windowsServers: 0,
      clusterAlerts: 12,
    },

  },
}
