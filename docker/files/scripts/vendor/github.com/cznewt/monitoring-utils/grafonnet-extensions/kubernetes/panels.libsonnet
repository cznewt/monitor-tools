local g = import 'g.libsonnet';

function(config, variables) {

  table: {
    local table = g.panel.table,
    local override = table.standardOptions.override,

    instances(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.appLabel,
                config.clusterLabel,
                'app_version',
                'namespace',
                'pod',
                'node',
                'Value #A',
                'Value #B',
                'Value #C',
                'Value #D',
              ],
            },
          },
        },
        {
          id: 'seriesToColumns',
          options: {
            byField: config.clusterLabel,
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
              'node 2': true,
              'pod 1': false,
              'pod 2': true,
              'pod 3': true,
              'pod 4': true,
              'namespace 1': false,
              'namespace 2': true,
              'namespace 3': true,
              'namespace 4': true,
              [config.clusterLabel + ' 1']: true,
              [config.clusterLabel + ' 2']: true,
              [config.clusterLabel + ' 3']: true,
              'Value #A': true,
            },
            indexByName: {
              [config.appLabel]: 0,
              app_version: 1,
              [config.clusterLabel]: 2,
              'namespace 1': 3,
              'pod 1': 4,
              node: 5,
              'Value #B': 6,
              'Value #C': 7,
              'Value #D': 8,
            },
            renameByName: {
              [config.appLabel]: 'Application',
              app_version: 'Version',
              [config.clusterLabel]: 'Cluster',
              'namespace 1': 'Namespace',
              'pod 1': 'Pod',
              node: 'Node',
              'Value #B': 'Uptime',
              'Value #C': 'Memory',
              'Value #D': 'CPU',
            },
          },
        },
        {
          id: 'sortBy',
          options: {
            fields: {},
            sort: [
              { field: 'CPU', desc: true },
              { field: 'Memory', desc: true },
            ],
          },
        },
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Node')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/linux-server/linux-server?var-cluster=${__data.fields["%(clusterLabel)s"]}&var-node=${__value.raw}' % config,
          },
        ]),
        override.byRegexp.new('Cluster')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/cluster/cluster?var-cluster=${__value.raw}',
          },
        ]),
        override.byRegexp.new('Pod')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/kubernetes-pod/kubernetes-pod?var-cluster=${__data.fields["%(clusterLabel)s"]}&var-namespace=${__data.fields["namespace"]}&var-pod=${__data.fields["pod"]}' % config,
          },
        ]),
        override.byRegexp.new('Namespace')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/kubernetes-namespace/kubernetes-namespace?var-cluster=${__data.fields["%(clusterLabel)s"]}&var-namespace=${__data.fields["namespace"]}' % config,
          },
        ]),
        override.byRegexp.new('Uptime')
        + override.byRegexp.withProperty('unit', 'dtdurations'),
        override.byRegexp.new('Memory')
        + override.byRegexp.withProperty('unit', 'decbytes'),
      ]),
  },

}
