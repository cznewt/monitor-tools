# App Instrumentation — multi-language telemetry test images

Small sample applications in many programming languages, each emitting one
telemetry signal (logs / metrics / traces) and shipping it through **Alloy**.
Use them to smoke-test an Alloy pipeline, exercise a backend, or demo
language-specific instrumentation.

Vendored from [`grafana/alloy-scenarios`](https://github.com/grafana/alloy-scenarios)
(`app-instrumentation/`), adapted so each stack can forward to a **remote**
backend (your Mimir / Loki / Tempo or Grafana Cloud) via a shared `.env`, while
still defaulting to a fully **local** bundled backend so it runs offline out of
the box.

## Stacks

Each directory is a self-contained `docker compose` stack: it builds one image
per language, runs Alloy, and (by default) a local backend + Grafana with a
pre-provisioned datasource.

| Stack | Signal | Transport | Languages (one image each) | Local backend |
| :--- | :--- | :--- | :--- | :--- |
| `logging/popular-logging-frameworks` | Logs | Docker log scrape → Loki | JavaScript (Pino), Python, Java (SLF4J+Logback), C# (MS.Extensions.Logging), C++ (spdlog), Go (Zap), PHP (Monolog) | Loki |
| `metrics/prometheus-client` | Metrics | scrape `/metrics` → remote_write | C#, Go, Java, Node, Python | Prometheus |
| `metrics/opentelemetry-sdk` | Metrics | OTLP push → OTLP/HTTP | C#, Go, Java, Node, Python | Prometheus |
| `traces/opentelemetry-sdk` | Traces | OTLP push → OTLP/gRPC | C#, Go, Java, Node, Python | Tempo |

Once up: **Grafana → http://localhost:3000** (anonymous admin),
**Alloy UI → http://localhost:12345**.

## Running

From the **monitor-tools repo root**, via `just`:

```bash
just instrumentation-logging        # logs, 7 languages
just instrumentation-metrics-prom   # Prometheus-client metrics, 5 languages
just instrumentation-metrics-otel   # OTLP metrics, 5 languages
just instrumentation-traces         # OTLP traces, 5 languages

just instrumentation-clean          # tear all of them down (-v)
```

Or directly:

```bash
docker compose -f extra/app-instrumentation/logging/popular-logging-frameworks/docker-compose.yml up --build
```

> **Run one stack at a time.** They all bind the same host ports (3000, 12345,
> 4317/4318, 9090, 3100/3200) and reuse container names, so they collide with
> each other — not with anything else in monitor-tools (Jupyter is on 8888).

## Forwarding to a remote backend

By default everything writes to the bundled local backend, so no setup is
needed. To forward a signal to a remote backend instead:

```bash
cp extra/app-instrumentation/.env.example extra/app-instrumentation/.env
# edit .env — fill in only the section(s) for the signal(s) you care about
```

All four stacks read this one shared `.env` (mounted into the Alloy container as
an optional `env_file`). The Alloy configs `coalesce(sys.env(...), "<local>")`,
so any var you leave blank falls back to the local backend.

| Stack | Vars |
| :--- | :--- |
| logging | `LOGS_PRIMARY_URL`, `LOGS_PRIMARY_USER`, `LOGS_PRIMARY_PASSWORD` |
| metrics-prom | `METRICS_PRIMARY_URL`, `METRICS_PRIMARY_USER`, `METRICS_PRIMARY_PASSWORD` |
| metrics-otel | `METRICS_OTLP_URL`, `METRICS_OTLP_AUTH` |
| traces | `TRACES_OTLP_URL`, `TRACES_OTLP_AUTH`, `TRACES_TLS_INSECURE` |

- **remote_write / Loki** use standard **basic auth** (username + password).
- **OTLP** stacks use an **`Authorization` header** — set `*_OTLP_AUTH` to the
  full value, typically `Basic <base64(instanceID:token)>`:
  ```bash
  printf '%s' 'INSTANCE_ID:TOKEN' | base64
  ```
- For a TLS OTLP traces endpoint (e.g. Grafana Cloud `…:443`) set
  `TRACES_TLS_INSECURE=false`. (OTLP/HTTP metrics pick TLS from the URL scheme.)
- `CLUSTER_NAME` / `ENV` are added as external labels to metrics and logs.

When forwarding remotely you can ignore the bundled Grafana and query the data
in your own Grafana instead; the local backend containers still start but go
unused.
