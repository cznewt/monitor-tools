local utils = (import './utils.libsonnet');

// App-platform Grafana resources (pushed through the Kubernetes-style API or
// grafanactl). A dashboard spec that carries `elements` + `layout` is a
// schema v2 board (dashboard.grafana.app/v2beta1); anything else is classic
// JSON wrapped as v0alpha1. The folder rides in the grafana.app/folder
// annotation, the way the app-platform API expects it.
local isV2(spec) = std.isObject(spec) && std.objectHas(spec, 'elements') && std.objectHas(spec, 'layout');
local ns(config) = if std.objectHas(config, 'grafanaNamespace') then config.grafanaNamespace else 'default';
// A board's folder. `grafanaDashboardFolder` is the title; the uid defaults to
// its slug and `grafanaDashboardFolderUid` overrides it. A folder may name a
// parent (`grafanaDashboardFolderParent` [+ ...ParentUid]), which is how a
// nested tree - Upstream / kubernetes-mixin - comes out of the config.
local opt(config, key) = if std.objectHas(config, key) then config[key] else null;
local hasFolder(config) =
  std.objectHas(config, 'grafanaDashboardFolder') && config.grafanaDashboardFolder != 'General';
local folderUid(config) =
  local explicit = opt(config, 'grafanaDashboardFolderUid');
  if explicit != null then explicit else utils.slugify(config.grafanaDashboardFolder);
local parentTitle(config) = opt(config, 'grafanaDashboardFolderParent');
local parentUid(config) =
  local explicit = opt(config, 'grafanaDashboardFolderParentUid');
  if explicit != null then explicit
  else if parentTitle(config) != null then utils.slugify(parentTitle(config))
  else null;
local folderMeta(config) =
  if hasFolder(config) then { annotations: { 'grafana.app/folder': folderUid(config) } } else {};
// one Folder resource; `parent` nests it the way a dashboard names its folder.
local folderResource(uid, title, config, parent=null) = std.manifestYamlDoc({
  apiVersion: 'folder.grafana.app/v1beta1',
  kind: 'Folder',
  metadata: { name: uid, namespace: ns(config) }
            + (if parent != null then { annotations: { 'grafana.app/folder': parent } } else {}),
  spec: { title: title },
}, indent_array_in_object=true, quote_keys=false);
// A mixin may emit whole resources (apiVersion/kind/metadata/spec) instead of
// bare specs - observ-viz's reference boards do, because each one names its own
// Grafana folder. Then the board's metadata wins over the config's folder.
local isResource(board) =
  std.isObject(board) && std.objectHas(board, 'spec') && std.objectHas(board, 'metadata')
  && std.objectHas(board, 'apiVersion');
local boardSpec(board) = if isResource(board) then board.spec else board;
local anns(board) =
  if isResource(board) && std.objectHas(board.metadata, 'annotations') then board.metadata.annotations else {};
local ann(board, key) = local a = anns(board); if std.objectHas(a, key) then a[key] else null;
// the folder a board carries: uid + title, and its parent (observ-viz writes
// the readable title and the parent in private annotations next to the uid).
local boardFolder(board) =
  local uid = ann(board, 'grafana.app/folder');
  if uid == null then null else {
    uid: uid,
    title: local t = ann(board, 'observ-viz.dev/folder-title'); if t != null then t else uid,
    parentUid: ann(board, 'observ-viz.dev/folder-parent-uid'),
    parentTitle: local t = ann(board, 'observ-viz.dev/folder-parent-title'); if t != null then t else ann(board, 'observ-viz.dev/folder-parent-uid'),
  };
// a board may instead carry the whole ancestor chain (observ-viz folderPath),
// for a tree deeper than parent/child: [{uid, title}, ...] ending in the folder
local boardFolderChain(board) =
  local raw = ann(board, 'observ-viz.dev/folder-path');
  if raw == null then [] else
    local path = std.parseJson(raw);
    [
      {
        uid: path[i].uid,
        title: if std.objectHas(path[i], 'title') then path[i].title else path[i].uid,
        parentUid: if i > 0 then path[i - 1].uid else null,
        parentTitle: if i > 0 then (if std.objectHas(path[i - 1], 'title') then path[i - 1].title else path[i - 1].uid) else null,
      }
      for i in std.range(0, std.length(path) - 1)
    ];
// private hints never reach Grafana
local publicAnns(board) = { [k]: anns(board)[k] for k in std.objectFields(anns(board)) if !std.startsWith(k, 'observ-viz.dev/') };

// the board's uid: a v0 board keeps the uid its mixin set when that is a valid
// Grafana uid (kubernetes-mixin links its boards by those uids), else the
// file name; a v2 spec carries no uid, so the file name is the uid.
local uidFor(stem, spec) =
  if !isV2(spec) && std.objectHas(spec, 'uid') && utils.validUid(spec.uid) then spec.uid
  else if utils.validUid(stem) then stem
  else std.substr(utils.slugify(stem), 0, 40);
local dashboard(name, board, config) =
  local spec = boardSpec(board);
  local own = publicAnns(board);
  std.manifestYamlDoc({
    apiVersion: if isV2(spec) then 'dashboard.grafana.app/v2beta1' else 'dashboard.grafana.app/v0alpha1',
    kind: 'Dashboard',
    metadata: { name: if isResource(board) then board.metadata.name else name, namespace: ns(config) }
              + (if std.length(own) > 0 then { annotations: own } else folderMeta(config)),
    spec: if isV2(spec) then spec else spec { uid: name },
  });

{
  // grafanaFolders(config, mixin): the config's folder (plus its parent), and
  // any folder the mixin's own boards name in their metadata.
  grafanaFolders(config, mixin={})::
    local boards = if std.objectHasAll(mixin, 'grafanaDashboards') then mixin.grafanaDashboards else {};
    local carried =
      std.prune([boardFolder(boards[name]) for name in std.objectFields(boards) if std.length(boardFolderChain(boards[name])) == 0])
      + std.flattenArrays([boardFolderChain(boards[name]) for name in std.objectFields(boards)]);
    // std.prune drops the null parentUid/parentTitle of a top-level folder, so
    // read both defensively: a board may name a folder with no parent at all.
    local par(f, key) = if std.objectHas(f, key) then f[key] else null;
    // parents first, then the folders themselves: a folder that is both (the
    // middle of a chain) must keep its own parent, so its real entry wins.
    local carriedParents = std.foldl(function(acc, f) acc
      + (if par(f, 'parentUid') != null then { [par(f, 'parentUid') + '.yaml']: folderResource(par(f, 'parentUid'), par(f, 'parentTitle'), config) } else {}), carried, {});
    local carriedFolders = carriedParents + std.foldl(function(acc, f) acc
      + { [f.uid + '.yaml']: folderResource(f.uid, f.title, config, par(f, 'parentUid')) }, carried, {});
    carriedFolders +
    (if !hasFolder(config) then {} else
      (if parentUid(config) != null
       then { [parentUid(config) + '.yaml']: folderResource(parentUid(config), parentTitle(config), config) }
       else {})
      + { [folderUid(config) + '.yaml']: folderResource(folderUid(config), config.grafanaDashboardFolder, config, parentUid(config)) }),
  grafanaDashboards(mixin, config)::
    local boards = if std.objectHasAll(mixin, 'grafanaDashboards') then mixin.grafanaDashboards else {};
    {
      [std.strReplace(name, '.json', '') + '.yaml']:
        dashboard(uidFor(std.strReplace(name, '.json', ''), boardSpec(boards[name])), boards[name], config)
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
