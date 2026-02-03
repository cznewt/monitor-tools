local g = import 'g.libsonnet';

function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  table: {
    local table = g.panel.table,
    local override = table.standardOptions.override,
    local step = table.standardOptions.threshold.step,

    clusters(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.clusterLabel,
                'Value #A',
                'Value #B',
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
            },
            indexByName: {
              [config.clusterLabel]: 0,
              'Value #A': 1,
              'Value #B': 2,
            },
            renameByName: {
              [config.clusterLabel]: 'Cluster',
              'Value #A': 'Nodes',
              'Value #B': 'Alerts',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Cluster')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '%(baseClusterLink)s?var-cluster=${__value.raw}' % config,
          },
        ]),
      ]),

    envApps(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.appPartOfLabel,
                'Value #A',
                'Value #B',
              ],
            },
          },
        },
        {
          id: 'seriesToColumns',
          options: {
            byField: config.appPartOfLabel,
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
            },
            indexByName: {
              [config.appPartOfLabel]: 0,
              'Value #A': 1,
              'Value #B': 2,
            },
            renameByName: {
              [config.appPartOfLabel]: 'App',
              'Value #A': 'Workloads',
              'Value #B': 'Alerts',
            },
          },
        },
      ]),

    clusterApps(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.appPartOfLabel,
                'Value #A',
                'Value #B',
              ],
            },
          },
        },
        {
          id: 'seriesToColumns',
          options: {
            byField: config.appPartOfLabel,
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
            },
            indexByName: {
              [config.appPartOfLabel]: 0,
              'Value #A': 1,
              'Value #B': 2,
            },
            renameByName: {
              [config.appPartOfLabel]: 'App',
              'Value #A': 'Pods',
              'Value #B': 'Alerts',
            },
          },
        },
      ]),

    linuxServers(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.clusterLabel,
                'node',
                'release',
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
            byField: 'node',
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
              'Value #A': true,
              'cluster 2': true,
              'cluster 3': true,
              'cluster 4': true,
            },
            indexByName: {
              [config.clusterLabel]: 0,
              node: 1,
              release: 2,
              'Value #B': 3,
              'Value #C': 4,
              'Value #D': 5,
            },
            renameByName: {
              [config.clusterLabel]: 'Cluster',
              node: 'Node',
              release: 'Release',
              'Value #B': 'CPU',
              'Value #C': 'Memory',
              'Value #D': 'Uptime',
            },
          },
        },
      ])
      + table.standardOptions.withMin(0)
      + table.standardOptions.withMax(100)
      + table.standardOptions.thresholds.withSteps([
        step.withColor('red') + step.withValue(null),
        step.withColor('yellow') + step.withValue(10),
        step.withColor('green') + step.withValue(30),
        step.withColor('yellow') + step.withValue(70),
        step.withColor('red') + step.withValue(90),
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Node')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '%(serverLinuxLink)s?var-cluster=${cluster}&var-node=${__value.raw}' % config,
          },
        ]),
        override.byRegexp.new('Uptime')
        + override.byRegexp.withProperty('unit', 'dtdurations'),
        override.byRegexp.new('CPU|Memory')
        + override.byRegexp.withProperty('custom.displayMode', 'basic')
        + override.byRegexp.withProperty('unit', 'percent'),
      ]),

    windowsServers(title, targets):
      g.ext.panel.table.base(title, targets)
      + table.queryOptions.withTransformations([
        {
          id: 'filterFieldsByName',
          options: {
            include: {
              names: [
                config.clusterLabel,
                'node',
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
            byField: 'node',
          },
        },
        {
          id: 'organize',
          options: {
            excludeByName: {
              'Value #A': true,
              'cluster 2': true,
              'cluster 3': true,
              'cluster 4': true,
            },
            indexByName: {
              cluster: 0,
              node: 1,
              'Value #A': 2,
              'Value #B': 3,
              'Value #C': 4,
              'Value #D': 5,
            },
            renameByName: {
              [config.clusterLabel]: 'Cluster',
              node: 'Node',
              'Value #B': 'CPU',
              'Value #C': 'Memory',
              'Value #D': 'Uptime',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Node')
        + override.byRegexp.withProperty('links', [
          {
            title: '${__value.raw}',
            url: '%(serverWindowsLink)s?var-cluster=${__data.fields["cluster"]}&var-node=${__value.raw}',
          },
        ]),
      ])
      + table.standardOptions.withOverrides([
        override.byRegexp.new('Uptime')
        + override.byRegexp.withProperty('unit', 'dtdurations'),
        override.byRegexp.new('Memory')
        + override.byRegexp.withProperty('unit', 'decbytes'),
        override.byRegexp.new('CPU|Memory')
        + override.byRegexp.withProperty('custom.displayMode', 'basic'),
      ]),

  },
}

/*{
  clusterNodesStatsRow(config)::
    g.row('Servers Overview')
    .addPanel(
      g.panel('Windows Server Statistics') +
      g.tablePanel([
        'sum by (cluster,node,role,friendly_name) (windows_os_info{%(windowsQuerySelector)s})' % config,
        |||
          100 - 100 * (
            sum by (cluster,node) (rate(windows_cpu_time_total{%(windowsQuerySelector)s,mode="idle"}[5m]))
            /
            sum by (cluster,node) (rate(windows_cpu_time_total{%(windowsQuerySelector)s}[5m]))
          )
        ||| % config,
        |||
          100 - 100 * (
            (
              sum by (cluster,node) (windows_os_physical_memory_free_bytes{%(windowsQuerySelector)s})
            )
            /
            sum by (cluster,node) (windows_cs_physical_memory_bytes{%(windowsQuerySelector)s})
          )
        ||| % config,
        'max by (cluster, node) (time() - windows_system_system_up_time{%(windowsQuerySelector)s})' % config,
        //'sum by (cluster,node) (ALERTS{%(windowsQuerySelector)s,alertstate="firing",severity!="critical"})' % config,
        //'sum by (cluster,node) (ALERTS{%(windowsQuerySelector)s,alertstate="firing",severity="critical"})' % config,
      ], {
        cluster: { alias: 'Cluster' },
        node: {
          alias: 'Server',
          link: config.grafanaDashboardLinks.windowsServer,
        },
        role: { alias: 'Role' },
        friendly_name: { alias: 'Alias' },
        'Value #A': { alias: 'Value', type: 'hidden' },
        'Value #B': {
          alias: 'CPU [%] ',
          colorMode: 'cell',
          decimals: 1,
          colors: [
            '#69B34C',
            '#FAB733',
            '#FF0D0D',
          ],
          thresholds: [
            '70',
            '90',
          ],
          type: 'number',
          unit: 'percent',
        },
        'Value #C': {
          alias: 'Mem [%]',
          colorMode: 'cell',
          decimals: 1,
          colors: [
            '#69B34C',
            '#FAB733',
            '#FF0D0D',
          ],
          thresholds: [
            '70',
            '90',
          ],
          type: 'number',
          unit: 'percent',
        },
        'Value #D': {
          alias: 'Uptime',
          type: 'number',
          unit: 'dtdurations',
        },
      }) +
      {
        height: '400px',
        sort: {
          col: 7,
          desc: true,
        },
      }
    )
    .addPanel(
      g.panel('Linux Server Statistics') +
      g.tablePanel(, {
        cluster: { alias: 'Cluster' },
        node: {
          alias: 'Server',
          link: config.grafanaDashboardLinks.linuxServer,
        },
        role: { alias: 'Role' },
        friendly_name: { alias: 'Alias' },
        release: { alias: 'Kernel', type: 'hidden' },
        'Value #A': { alias: 'Value', type: 'hidden' },
        'Value #B': {
          alias: 'CPU [%]',
          colorMode: 'cell',
          decimals: 1,
          colors: [
            '#69B34C',
            '#FAB733',
            '#FF0D0D',
          ],
          thresholds: [
            '70',
            '90',
          ],
          type: 'number',
          unit: 'percent',
        },
        'Value #C': {
          alias: 'Mem [%]',
          colorMode: 'cell',
          decimals: 1,
          colors: [
            '#69B34C',
            '#FAB733',
            '#FF0D0D',
          ],
          thresholds: [
            '70',
            '90',
          ],
          type: 'number',
          unit: 'percent',
        },
        'Value #D': {
          alias: 'Uptime',
          type: 'number',
          unit: 'dtdurations',
        },
      }) +
      {
        height: '400px',
        sort: {
          col: 8,
          desc: true,
        },
      }
    ),
  clusterWindowsNodesStatsRow(config)::
    g.row('Windows Servers Overview')
    .addPanel(
      g.panel('Server Statistics') +
      g.tablePanel([
        'sum by (cluster,node,product,version) (windows_os_info{%(windowsQuerySelector)s})' % config,
      ], {
        cluster: { alias: 'Cluster' },
        node: { alias: 'Server' },
        product: { alias: 'OS' },
        version: { alias: 'Version' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),
  clusterLinuxNodesStatsRow(config)::
    g.row('Linux Servers Overview')
    .addPanel(
      g.panel('Server Statistics') +
      g.tablePanel([
        'sum by (cluster,node,product,version) (node_os_info{%(linuxQuerySelector)s})' % config,
      ], {
        cluster: { alias: 'Cluster' },
        node: { alias: 'Server' },
        product: { alias: 'OS' },
        version: { alias: 'Version' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),
  clusterWorkloadStatsRow(config)::
    g.row('Workload Overview')
    .addPanel(
      g.panel('Service Stats') +
      g.tablePanel([
        'sum by (cluster,app_part_of,app_component) (up{%(appQuerySelector)s,node=~"[a-z0-9]+"})' % config,
      ], {
        app_part_of: { alias: 'System' },
        app_component: { alias: 'Component' },
        Value: { alias: 'Value', type: 'hidden' },
      }) +
      { height: '400px' }
    ),

}*/
