local g = import 'g.libsonnet';

function(config) {

  base(title, description=null, slug=null, tags=null):
    local uid = std.strReplace(if slug == null then g.util.string.slugify(title) else slug, '--', '-');
    local _tags = if tags != null then tags else if std.objectHas(config, 'tags') then config.tags else [];
    g.dashboard.new(title)
    + g.dashboard.withUid(uid)
    + g.dashboard.withRefresh('5m')
    + g.dashboard.time.withFrom('now-1h')
    + g.dashboard.time.withTo('now')
    + (if description != null then g.dashboard.withDescription(description) else {})
    + (if _tags != [] then g.dashboard.withTags(_tags) else {})
    + (if std.count(_tags, 'env-level') > 0 then g.dashboard.withLinks([
         g.dashboard.link.dashboards.new('Environment dashboards', ['env-level'])
         + g.dashboard.link.dashboards.options.withAsDropdown(true)
         + g.dashboard.link.dashboards.options.withIncludeVars(true),
       ]) else {})
    + (if std.count(_tags, 'cluster-level') > 0 then g.dashboard.withLinks([
         g.dashboard.link.dashboards.new('Cluster dashboards', ['cluster-level'])
         + g.dashboard.link.dashboards.options.withAsDropdown(true)
         + g.dashboard.link.dashboards.options.withIncludeVars(true),
       ]) else {})
    + (if std.count(_tags, 'server-level') > 0 then g.dashboard.withLinks([
         g.dashboard.link.dashboards.new('Server dashboards', ['server-level'])
         + g.dashboard.link.dashboards.options.withAsDropdown(true)
         + g.dashboard.link.dashboards.options.withIncludeVars(true),
       ]) else {}),

  runbook(runbook, variables, rows):
    local title = 'Alert ' + runbook.alertname + ' runbook';
    g.dashboard.new(title)
    + g.dashboard.withUid('runbook' + g.util.string.slugify(runbook.alertname))
    + g.dashboard.withTags(['runbook'])
    + g.dashboard.withRefresh('5m')
    + g.dashboard.time.withFrom('now-1h')
    + g.dashboard.time.withTo('now')
    + g.dashboard.withPanels(rows.alertRunbook(runbook))
    + g.dashboard.withVariables(variables.toList()),

}
