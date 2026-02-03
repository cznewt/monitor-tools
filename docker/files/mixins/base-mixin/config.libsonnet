local g = import 'g.libsonnet';

{
  _config+:: g.ext.base.config {

    linuxEnabled: true,
    windowsEnabled: false,

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
