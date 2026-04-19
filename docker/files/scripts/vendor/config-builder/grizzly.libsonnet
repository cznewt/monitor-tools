local utils = (import './utils.libsonnet');

{
  grizzlyResources(mixinParam)::
    local mixin = { grafanaDashboards+:: {}, prometheusAlerts+:: { groups+:: [] }, prometheusRules+:: { groups+:: [] } } + mixinParam;
    local grafanaDashboardFolder = if std.objectHas(mixin, 'grafanaDashboardFolder') then mixin.grafanaDashboardFolder else 'General';
    {
      [if grafanaDashboardFolder != 'General' then 'folder']: {
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'DashboardFolder',
        metadata: {
          name: utils.slugify(grafanaDashboardFolder),
        },
        spec: {
          title: grafanaDashboardFolder,
        },
      },
      dashboards: {
        [file]: {
          apiVersion: 'grizzly.grafana.com/v1alpha1',
          kind: 'Dashboard',
          metadata: {
            [if grafanaDashboardFolder != 'General' then 'folder']: utils.slugify(grafanaDashboardFolder),
            name: std.md5(file),
          },
          spec: mixin.grafanaDashboards[file] {
            uid: std.md5(file),
          },
        }
        for file in std.objectFields(mixin.grafanaDashboards)
      },
      prometheus_rules: std.map(
        function(group)
          {
            apiVersion: 'grizzly.grafana.com/v1alpha1',
            kind: 'PrometheusRuleGroup',
            metadata: {
              namespace: utils.slugify(grafanaDashboardFolder),
              name: group.name,
            },
            spec: group,
          },
        mixin.prometheusAlerts.groups
      ),
    },
  grafanaDatasources(config)::
    {
      [name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'Datasource',
        metadata: {
          name: name,
        },
        spec: config.grafana.datasources[name],
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(config.grafana.datasources)
    },
  grafanaFolders(config)::
    {
      [if std.objectHas(config, 'grafanaDashboardFolder') then utils.slugify(config.grafanaDashboardFolder) + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'DashboardFolder',
        metadata: {
          name: config.grafanaDashboardFolder,
        },
        spec: {
          'title': config.grafanaDashboardFolder,
          'uid': utils.slugify(config.grafanaDashboardFolder),
        },
      }, indent_array_in_object=true, quote_keys=false)
    },
  grafanaDashboards(mixin, config)::
    local folder = if std.objectHas(config, 'grafanaDashboardFolder') then config.grafanaDashboardFolder else 'General';
    {
      [if std.endsWith(name, '.json') then std.strReplace(name, '.json', '.yaml') else name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'Dashboard',
        metadata: {
          folder: utils.slugify(folder),
          name: std.strReplace(name, '.json', ''),
        },
        spec: mixin.grafanaDashboards[name] { uid: std.strReplace(name, '.json', '') },
      }, indent_array_in_object=true, quote_keys=false)
      for name in std.objectFields(if std.objectHasAll(mixin, 'grafanaDashboards') then mixin.grafanaDashboards else {})
    },
  staticGrafanaDashboard(name, rawJson, config)::
    local datasources = if std.objectHas(config, 'datasources') then config.datasources else {};
    local applied = std.foldl(
      function(acc, k) std.strReplace(acc, '${' + k + '}', datasources[k]),
      std.objectFields(datasources),
      rawJson
    );
    local dashboard = std.parseJson(applied);
    local folder = if std.objectHas(config, 'grafanaDashboardFolder') then config.grafanaDashboardFolder else 'General';
    local uid = if std.objectHas(config, 'uid') then config.uid else utils.slugify(name);
    {
      [name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'Dashboard',
        metadata: {
          [if folder != 'General' then 'folder']: utils.slugify(folder),
          name: uid,
        },
        spec: dashboard { uid: uid },
      }, indent_array_in_object=true, quote_keys=false),
    },
  staticGrafanaDashboardPlain(name, rawJson, config)::
    local datasources = if std.objectHas(config, 'datasources') then config.datasources else {};
    local applied = std.foldl(
      function(acc, k) std.strReplace(acc, '${' + k + '}', datasources[k]),
      std.objectFields(datasources),
      rawJson
    );
    local dashboard = std.parseJson(applied);
    local uid = if std.objectHas(config, 'uid') then config.uid else utils.slugify(name);
    {
      [name + '.json']: std.manifestJsonEx(dashboard { uid: uid }, '  '),
    },
  prometheusRuleGroups(mixin, config)::
    local namespace = if std.objectHas(config, 'prometheusNamespace') then config.prometheusNamespace else 'default';
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'PrometheusRuleGroup',
        metadata: {
          name: group.name,
          namespace: namespace,
        },
        spec: {
          rules: group.rules,
        },
      }, indent_array_in_object=true, quote_keys=false)
      for group in mixin.prometheusRules.groups
    } +
    {
      [group.name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'grizzly.grafana.com/v1alpha1',
        kind: 'PrometheusRuleGroup',
        metadata: {
          name: group.name,
          namespace: namespace,
        },
        spec: {
          rules: group.rules,
        },
      }, indent_array_in_object=true, quote_keys=false)
      for group in mixin.prometheusAlerts.groups
    },
}
