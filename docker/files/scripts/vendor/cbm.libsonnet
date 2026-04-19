local builder = (import 'cb.libsonnet');

{
  plainGrafanaDashboards(name, mixin, config)::
    builder.plain.grafanaDashboards(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  plainPrometheusRules(name, mixin, config)::
    builder.plain.promRuleGroups(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  grizzlyGrafanaFolders(name, mixin, config)::
    builder.grizzly.grafanaFolders(config.mixins[name].config + {mixinName: name}),
  grizzlyGrafanaDashboards(name, mixin, config)::
    builder.grizzly.grafanaDashboards(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  lokitoolLokiRules(name, mixin, config)::
    builder.lokitool.lokiRuleGroups(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  mimirtoolMimirRules(name, mixin, config)::
    builder.mimirtool.promRuleGroups(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  mimirtoolAlertmanagerConfig(config)::
    builder.mimirtool.alertmanagerConfig(config),
  pyrraRules(config)::
    builder.pyrra.pyrraRules(config),
  slothRules(config)::
    builder.sloth.slothRules(config),
  grizzlyStaticDashboard(name, rawJson, config)::
    builder.grizzly.staticGrafanaDashboard(name, rawJson, config.dashboards[name].config + {dashboardName: name}),
  plainStaticDashboard(name, rawJson, config)::
    builder.grizzly.staticGrafanaDashboardPlain(name, rawJson, config.dashboards[name].config + {dashboardName: name}),
  grizzlyDashboardFolders(name, config)::
    builder.grizzly.grafanaFolders(config.dashboards[name].config + {dashboardName: name}),
}
