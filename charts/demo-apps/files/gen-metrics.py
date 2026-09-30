"""Serve the Prometheus metrics of a simulated HTTP service, OTel-named.

A background thread simulates RATE_PER_SECOND requests per second across a few
routes and records them as the OTel HTTP server metrics the observ-viz HTTP
server and RED boards read:

  http_server_request_duration_seconds (histogram)
      {http_request_method, http_route, http_response_status_code}
  http_server_active_requests (gauge) {http_request_method}

Every INCIDENT_EVERY_SECONDS an incident window of INCIDENT_DURATION_SECONDS
raises the error ratio and the latency together, so RED alerts can fire.
Scraped through the pod's k8s.grafana.com annotations.
"""
import os
import random
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "9100"))
RATE = float(os.environ.get("RATE_PER_SECOND", "5"))
ERROR_RATIO = float(os.environ.get("ERROR_RATIO", "0.05"))
INCIDENT_EVERY = float(os.environ.get("INCIDENT_EVERY_SECONDS", "1800"))
INCIDENT_DURATION = float(os.environ.get("INCIDENT_DURATION_SECONDS", "300"))
INCIDENT_ERROR_RATIO = float(os.environ.get("INCIDENT_ERROR_RATIO", "0.5"))
INCIDENT_LATENCY_FACTOR = float(os.environ.get("INCIDENT_LATENCY_FACTOR", "5"))

# the OTel default boundaries for http.server.request.duration
BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0]
# method, route, weight, median latency (s)
ROUTES = [
    ("GET", "/", 30, 0.015),
    ("GET", "/products", 25, 0.04),
    ("GET", "/products/{id}", 20, 0.025),
    ("POST", "/cart", 10, 0.06),
    ("POST", "/cart/checkout", 8, 0.18),
    ("GET", "/health", 7, 0.002),
]

lock = threading.Lock()
histograms = {}  # (method, route, status) -> [bucket counts..., sum, count]
active = {"GET": 0, "POST": 0}


def in_incident(now):
    return INCIDENT_EVERY > 0 and (now % INCIDENT_EVERY) < INCIDENT_DURATION


def record(method, route, status, seconds):
    with lock:
        h = histograms.setdefault((method, route, str(status)), [0] * len(BUCKETS) + [0.0, 0])
        for i, bound in enumerate(BUCKETS):
            if seconds <= bound:
                h[i] += 1
        h[-2] += seconds
        h[-1] += 1


def simulate():
    mean_gap = 1.0 / RATE if RATE > 0 else 1.0
    while True:
        now = time.time()
        incident = in_incident(now)
        method, route, _, median = random.choices(ROUTES, weights=[r[2] for r in ROUTES])[0]
        seconds = random.lognormvariate(0, 0.4) * median * (INCIDENT_LATENCY_FACTOR if incident else 1)
        roll = random.random()
        error_ratio = INCIDENT_ERROR_RATIO if incident else ERROR_RATIO
        if roll < error_ratio:
            status = random.choice([500, 502, 503, 504])
        elif roll < error_ratio + 0.04:
            status = random.choice([400, 401, 404, 409])
        else:
            status = 201 if method == "POST" else 200
        with lock:
            active[method] = random.randint(0, 3 if not incident else 12)
        record(method, route, status, seconds)
        time.sleep(random.uniform(0.5, 1.5) * mean_gap)


def exposition():
    out = [
        "# HELP http_server_request_duration_seconds Duration of HTTP server requests.",
        "# TYPE http_server_request_duration_seconds histogram",
    ]
    with lock:
        for (method, route, status), h in sorted(histograms.items()):
            labels = f'http_request_method="{method}",http_route="{route}",http_response_status_code="{status}"'
            for i, bound in enumerate(BUCKETS):
                out.append(f'http_server_request_duration_seconds_bucket{{{labels},le="{bound}"}} {h[i]}')
            out.append(f'http_server_request_duration_seconds_bucket{{{labels},le="+Inf"}} {h[-1]}')
            out.append(f"http_server_request_duration_seconds_sum{{{labels}}} {h[-2]}")
            out.append(f"http_server_request_duration_seconds_count{{{labels}}} {h[-1]}")
        out += [
            "# HELP http_server_active_requests Number of active HTTP server requests.",
            "# TYPE http_server_active_requests gauge",
        ]
        for method, n in sorted(active.items()):
            out.append(f'http_server_active_requests{{http_request_method="{method}"}} {n}')
    return "\n".join(out) + "\n"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.split("?")[0] != "/metrics":
            self.send_error(404)
            return
        body = exposition().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):  # keep stdout for real events
        pass


if __name__ == "__main__":
    threading.Thread(target=simulate, daemon=True).start()
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
