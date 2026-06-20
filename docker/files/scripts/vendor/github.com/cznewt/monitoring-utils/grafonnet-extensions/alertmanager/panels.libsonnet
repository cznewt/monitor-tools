local g = import 'g.libsonnet';

function(config, variables) {

  table: {
    local table = g.panel.table,
    local override = table.standardOptions.override,

    clusterAlerts(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                'alertname',
                'summary',
                'severity',
                'namespace',
                'pod',
                'node',
              ],
            },
          },
        },
        {
          id: 'seriesToColumns',
          options: {
            byField: 'alertname',
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
            },
            indexByName: {
              alertname: 0,
              summary: 1,
              severity: 2,
              namespace: 3,
              pod: 4,
              instance: 5,
            },
            renameByName: {
              alertname: 'Alert',
              summary: 'Summary',
              severity: 'Severity',
              namespace: 'Namespace',
              pod: 'Pod',
              node: 'Node',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Alert')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/runbook${__value.raw}/runbook${__value.raw}',
          },
        ]),
        override.byRegexp.new('Node')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/linux-server/linux-server?var-cluster=${cluster}&var-node=${__value.raw}',
          },
        ]),
        override.byRegexp.new('Namespace')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/k8sresourcenamespace/k8sresourcenamespace?var-cluster=${cluster}&var-namespace=${__value.raw}',
          },
        ]),
        override.byRegexp.new('Pod')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '/d/k8sresourcenamespace/k8sresourcenamespace?var-cluster=${cluster}&var-namespace=${__data.fields["namespace"]}&var-pod=${__value.raw}',
          },
        ]),

      ]),
  },
}
