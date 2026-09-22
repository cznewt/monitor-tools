local utils = (import './utils.libsonnet');

// App-platform Grafana resources (pushed through the Kubernetes-style API or
// grafanactl). A dashboard spec that carries `elements` + `layout` is a
// schema v2 board (dashboard.grafana.app/v2beta1); anything else is classic
// JSON wrapped as v0alpha1. The folder rides in the grafana.app/folder
// annotation, the way the app-platform API expects it.
local isV2(spec) = std.isObject(spec) && std.objectHas(spec, 'elements') && std.objectHas(spec, 'layout');
local ns(config) = if std.objectHas(config, 'grafanaNamespace') then config.grafanaNamespace else 'default';
local folderMeta(config) =
  if std.objectHas(config, 'grafanaDashboardFolder') && config.grafanaDashboardFolder != 'General'
  then { annotations: { 'grafana.app/folder': utils.slugify(config.grafanaDashboardFolder) } } else {};
// the board's uid: a v0 board keeps the uid its mixin set when that is a valid
// Grafana uid (kubernetes-mixin links its boards by those uids), else the
// file name; a v2 spec carries no uid, so the file name is the uid.
local uidFor(stem, spec) =
  if !isV2(spec) && std.objectHas(spec, 'uid') && utils.validUid(spec.uid) then spec.uid
  else if utils.validUid(stem) then stem
  else std.substr(utils.slugify(stem), 0, 40);
local dashboard(name, spec, config) = std.manifestYamlDoc({
  apiVersion: if isV2(spec) then 'dashboard.grafana.app/v2beta1' else 'dashboard.grafana.app/v0alpha1',
  kind: 'Dashboard',
  metadata: { name: name, namespace: ns(config) } + folderMeta(config),
  spec: if isV2(spec) then spec else spec { uid: name },
});

{
  grafanaFolders(config)::
    {
      [if std.objectHas(config, 'grafanaDashboardFolder') && config.grafanaDashboardFolder != 'General' then utils.slugify(config.grafanaDashboardFolder) + '.yaml']: std.manifestYamlDoc({
        apiVersion: 'folder.grafana.app/v1beta1',
        kind: 'Folder',
        metadata: {
          name: utils.slugify(config.grafanaDashboardFolder),
          namespace: ns(config),
        },
        spec: {
          title: config.grafanaDashboardFolder,
        },
      }, indent_array_in_object=true, quote_keys=false),
    },
  grafanaDashboards(mixin, config)::
    local boards = if std.objectHasAll(mixin, 'grafanaDashboards') then mixin.grafanaDashboards else {};
    {
      [std.strReplace(name, '.json', '') + '.yaml']:
        dashboard(uidFor(std.strReplace(name, '.json', ''), boards[name]), boards[name], config)
      for name in std.objectFields(boards)
    },
  // a released dashboard JSON (config.dashboards.<name>) with the datasource
  // input substitution the grizzly static builder does.
  staticGrafanaDashboard(name, rawJson, config)::
    local plain = (import './grizzly.libsonnet').staticGrafanaDashboardPlain(name, rawJson, config);
    {
      [std.strReplace(k, '.json', '') + '.yaml']:
        dashboard(if std.objectHas(config, 'uid') then config.uid else uidFor(std.strReplace(k, '.json', ''), std.parseJson(plain[k])), std.parseJson(plain[k]), config)
      for k in std.objectFields(plain)
    },
}
