# Alert Handler — Alertmanager actions, end to end

A three-container stack that shows what an alert can *do* once it leaves
Alertmanager:

```
Prometheus ──rule fires──> Alertmanager ──webhook──> alert-handler ──> actions
    ▲                                                      │              · run a runbook command
    └────────────────── scrapes /metrics ──────────────────┘              · call an HTTP endpoint
                                                                          · (in a cluster) restart,
                                                                            scale, delete, cordon
```

`DemoWorkloadUnhealthy` fires on its own about 30 seconds after start, carrying
the labels a Kubernetes alert would (`namespace`, `deployment`, `severity`), so
the handler's rules read exactly as they would in a real cluster.

The handler is also scraped by the same Prometheus, and two of the demo rules
alert on the handler itself — a failing action or a rejected config reload.

## Run it

The image comes from the service catalog
(`monitor-services/alert-handler`); build it once if you do not have it:

```bash
cd <service-catalog>/monitor-services/alert-handler && just container-build
```

Then, from the repository root:

```bash
just alert-handler-demo          # foreground, ctrl-c to stop
just alert-handler-demo-logs     # what the handler did with each alert
just alert-handler-demo-clean    # tear down
```

Host ports are overridable, because a monitoring workstation usually has
something on 9090 already:

```bash
PROMETHEUS_PORT=19090 ALERTMANAGER_PORT=19093 ALERT_HANDLER_PORT=18080 just alert-handler-demo
```

## What to look for

Within a minute the handler log shows the rules matching and the actions
running:

```
INFO [action:log] firing DemoWorkloadUnhealthy (warning) ns=demo summary=demo-app in namespace demo is unhealthy
INFO rule demo-remediation ran exec for DemoWorkloadUnhealthy{deployment=demo-app,...}: exit 0: runbook: would recycle demo-app in demo, status=firing
INFO rule demo-remediation ran http for DemoWorkloadUnhealthy{deployment=demo-app,...}: GET http://alertmanager:9093/api/v2/status -> 200
```

and the same story is in the metrics:

```bash
curl -s localhost:8080/metrics | grep alert_handler_actions_total
curl -s localhost:8080/rules            # the loaded rules, as parsed
open http://localhost:9090/alerts       # Prometheus
open http://localhost:9093              # Alertmanager
```

A useful thing to try: edit `handler/config.yaml`, then
`docker compose kill -s HUP alert-handler` — the handler reloads the rules
without dropping the webhook listener, and refuses a broken file in favour of
the rules it already has (`alert_handler_config_valid` goes to 0, which the
`AlertHandlerConfigInvalid` rule alerts on).

## Files

| File | What it holds |
| --- | --- |
| `docker-compose.yml` | The three services and their ports |
| `prometheus/prometheus.yml` | Scrape config (handler included) and the Alertmanager target |
| `prometheus/alert-rules.yml` | The demo alert plus two rules that watch the handler |
| `alertmanager/alertmanager.yml` | One route, one webhook receiver, short timers |
| `handler/config.yaml` | The handler's own rules: what matches and what runs |

## Taking it further

The Kubernetes actions (`k8s_rollout_restart`, `k8s_scale`, `k8s_delete_pod`,
`k8s_cordon_node`, `k8s_annotate`) are commented out in `handler/config.yaml`:
compose has no API server, so they would only produce failures here. In a
cluster the catalog component renders the ServiceAccount and the ClusterRole
they need — see `monitor-services/alert-handler/README.md`.

To point the demo handler at *your* Alertmanager instead, add a webhook
receiver over there:

```yaml
receivers:
  - name: alert-handler
    webhook_configs:
      - url: http://<host>:8080/alert
        send_resolved: true
```
