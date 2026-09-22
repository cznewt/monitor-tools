local g = import 'g.libsonnet';

// One home + one detail board per enabled setup (config.baseSetup: a name or
// a list of names from config.baseSetups). The env-cluster-system setup keeps
// the historical files base-home / base-cluster.
{
  local config = $._config,
  local dashboards = g.ext.base.dashboards(config),
  local enabled = if std.isArray(config.baseSetup) then config.baseSetup else [config.baseSetup],

  local boards(name) =
    local setup = config.baseSetups[name];
    local h = (import './hierarchy.libsonnet')(config, setup);
    // the server tables read their selectors from config
    local serverConfig = config { linuxQuerySelector: h.nodeScope, windowsQuerySelector: h.nodeScope };
    local rows = (import './rows.libsonnet')(serverConfig, h);
    local panels = (import './panels.libsonnet')(serverConfig, h);
    local queries = (import './queries.libsonnet')(serverConfig, h);
    local both = config.linuxEnabled && config.windowsEnabled;
    local servers =
      (if config.linuxEnabled then [
         panels.table.linuxServers('Linux servers', queries.linuxServers)
         + { gridPos: { h: 10, w: if both then 12 else 24, x: 0, y: 12 } },
       ] else [])
      + (if config.windowsEnabled then [
           panels.table.windowsServers('Windows servers', queries.windowsServers)
           + { gridPos: { h: 10, w: if both then 12 else 24, x: if both then 12 else 0, y: 12 } },
         ] else []);
    {
      [setup.home.file + '.json']:
        dashboards.base(setup.home.title, slug=setup.home.uid, tags=setup.home.tags)
        + g.dashboard.withVariables(h.homeVariables)
        + g.dashboard.withPanels(rows.homeDashboards + h.homePanels(16) + h.homeAlertPanels(28)),

      [setup.detail.file + '.json']:
        dashboards.base(setup.detail.title, slug=setup.detail.uid, tags=setup.detail.tags)
        + g.dashboard.withVariables(h.detailVariables)
        + g.dashboard.withPanels(h.detailPanels(0) + servers + h.detailAlertPanels(22)),
    },

  grafanaDashboards+:: std.foldl(function(acc, name) acc + boards(name), enabled, {}),
}
