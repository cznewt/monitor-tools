
{
  grafanaDashboards+:: {
    'unifi-poller-client-insights.json': (import './11315_rev9.json') {
      title: "UniFi / Client Insights",
    },
    'unifi-poller-uap-insights.json': (import './11314_rev10.json') {
      title: "UniFi / UAP Insights",
    },
    'unifi-poller-network-sites.json': (import './11311_rev5.json') {
      title: "UniFi / Network Sites",
    },
  },
}
  