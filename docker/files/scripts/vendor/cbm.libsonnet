local builder = (import 'cb.libsonnet');

{
  plainGrafanaDashboards(name, mixin, config)::
    builder.plain.grafanaDashboards(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  plainPrometheusRules(name, mixin, config)::
    builder.plain.promRuleGroups(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  configmapPrometheusRules(name, mixin, config)::
    builder.configmap.prometheusRuleGroups(
      mixin + {_config+:: config.mixins[name].config},
      config.mixins[name].config + {
        mixinName: name,
        prometheusNamespace:
          if std.objectHasAll(config, 'prometheus') && std.objectHasAll(config.prometheus, 'namespace')
          then config.prometheus.namespace else 'default',
        prometheusLabels:
          if std.objectHasAll(config, 'prometheus') && std.objectHasAll(config.prometheus, 'labels')
          then config.prometheus.labels else {},
      },
    ),
  configmapLokiRules(name, mixin, config)::
    builder.configmap.lokiRuleGroups(
      mixin + {_config+:: config.mixins[name].config},
      config.mixins[name].config + {
        mixinName: name,
        lokiNamespace:
          if std.objectHasAll(config, 'loki') && std.objectHasAll(config.loki, 'namespace')
          then config.loki.namespace else 'default',
        lokiLabels:
          if std.objectHasAll(config, 'loki') && std.objectHasAll(config.loki, 'labels')
          then config.loki.labels else {},
      },
    ),
  grizzlyGrafanaFolders(name, mixin, config)::
    builder.grizzly.grafanaFolders(config.mixins[name].config + {mixinName: name}),
  grizzlyGrafanaDashboards(name, mixin, config)::
    builder.grizzly.grafanaDashboards(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  grizzlyGrafanaLibraryPanels(name, mixin, config)::
    builder.grizzly.grafanaLibraryPanels(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
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
  grafanactlGrafanaFolders(name, mixin, config)::
    builder.grafanactl.grafanaFolders(config.mixins[name].config + {mixinName: name}),
  grafanactlGrafanaDashboards(name, mixin, config)::
    builder.grafanactl.grafanaDashboards(mixin + {_config+:: config.mixins[name].config}, config.mixins[name].config + {mixinName: name}),
  grafanactlStaticDashboard(name, rawJson, config)::
    builder.grafanactl.staticGrafanaDashboard(name, rawJson, config.dashboards[name].config + {dashboardName: name}),
  grafanactlDashboardFolders(name, config)::
    builder.grafanactl.grafanaFolders(config.dashboards[name].config + {dashboardName: name}),
  grizzlyStaticDashboard(name, rawJson, config)::
    builder.grizzly.staticGrafanaDashboard(name, rawJson, config.dashboards[name].config + {dashboardName: name}),
  plainStaticDashboard(name, rawJson, config)::
    builder.grizzly.staticGrafanaDashboardPlain(name, rawJson, config.dashboards[name].config + {dashboardName: name}),
  grizzlyDashboardFolders(name, config)::
    builder.grizzly.grafanaFolders(config.dashboards[name].config + {dashboardName: name}),
}
