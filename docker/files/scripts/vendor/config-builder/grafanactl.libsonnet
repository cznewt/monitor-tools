local utils = (import './utils.libsonnet');

{
  grafanaFolders(config)::
    {
      [if std.objectHas(config, 'grafanaDashboardFolder') then utils.slugify(config.grafanaDashboardFolder) + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'folder.grafana.app/v0alpha1',
        kind: 'Folder',
        metadata: {
          name: config.grafanaDashboardFolder,
          namespace: if std.objectHas(config, 'grafanaNamespace') then config.grafanaNamespace else 'default'
        },
        spec: {
          'title': config.grafanaDashboardFolder,
          'uid': utils.slugify(config.grafanaDashboardFolder),
        },
      }, indent_array_in_object=true, quote_keys=false)
    },
  grafanaDashboards(mixin, folder='General')::
    {
      [if std.endsWith(name, '.json') then std.strReplace(name, '.json', '.yaml') else name + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'dashboard.grafana.app/v0alpha1',
        kind: 'Dashboard',
        metadata: {
          folder: utils.slugify(folder),
          name: std.strReplace(name, '.json', ''),
          namespace: if std.objectHas(config, 'grafanaNamespace') then config.grafanaNamespace else 'default'
        },
        spec: mixin.grafanaDashboards[name],
      })
      for name in std.objectFields(mixin.grafanaDashboards)
    },
}
