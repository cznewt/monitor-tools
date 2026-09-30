"""Serve the Prometheus metrics of a simulated HTTP service, OTel-named.

A background thread simulates RATE_PER_SECOND requests per second across a few
routes and records them as the OTel HTTP server metrics the observ-viz HTTP
server and RED boards read:

  http_server_request_duration_seconds (histogram)
      {http_request_method, http_route, http_response_status_code}
  http_server_active_requests (gauge) {http_request_method}

Every INCIDENT_EVERY_SECONDS an incident window of INCIDENT_DURATION_SECONDS
raises the error ratio and the latency together, so RED alerts can fire. The
generator is also the incident switch of its release, on demand:

  POST   /incident?seconds=300[&errorRatio=0.5][&latencyFactor=5]  open a window now
  GET    /incident                                                 the current window
  DELETE /incident                                                 end the current window

each answering the window as JSON ({"active", "until", "seconds_remaining",
"source", "errorRatio", "latencyFactor"}); the logs and traces generators poll
GET /incident and follow it. Its state is exported too:
demo_incident_active and demo_incident_seconds_remaining.
Scraped through the pod's k8s.grafana.com annotations.
"""
import json
import os
import random
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

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
# the on-demand window, and the end of a scheduled one DELETE cut short
manual = {"until": 0.0, "errorRatio": INCIDENT_ERROR_RATIO, "latencyFactor": INCIDENT_LATENCY_FACTOR}
suppressed_until = 0.0


def incident(now):
    """The window in force at `now`: an on-demand one wins over the schedule."""
    if now < manual["until"]:
        return {"active": True, "until": manual["until"], "source": "manual",
                "errorRatio": manual["errorRatio"], "latencyFactor": manual["latencyFactor"]}
    if INCIDENT_EVERY > 0 and (now % INCIDENT_EVERY) < INCIDENT_DURATION and now >= suppressed_until:
        return {"active": True, "until": now - now % INCIDENT_EVERY + INCIDENT_DURATION, "source": "schedule",
                "errorRatio": INCIDENT_ERROR_RATIO, "latencyFactor": INCIDENT_LATENCY_FACTOR}
    return {"active": False, "until": 0, "source": "", "errorRatio": ERROR_RATIO, "latencyFactor": 1.0}


def incident_json(now):
    w = incident(now)
    return dict(w, until=round(w["until"], 3), seconds_remaining=max(0, round(w["until"] - now)) if w["active"] else 0)


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
        with lock:
            w = incident(time.time())
        method, route, _, median = random.choices(ROUTES, weights=[r[2] for r in ROUTES])[0]
        seconds = random.lognormvariate(0, 0.4) * median * w["latencyFactor"]
        roll = random.random()
        error_ratio = w["errorRatio"]
        if roll < error_ratio:
            status = random.choice([500, 502, 503, 504])
        elif roll < error_ratio + 0.04:
            status = random.choice([400, 401, 404, 409])
        else:
            status = 201 if method == "POST" else 200
        with lock:
            active[method] = random.randint(0, 12 if w["active"] else 3)
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
        w = incident_json(time.time())
    out += [
        "# HELP demo_incident_active Whether an incident window is open (1), scheduled or on demand.",
        "# TYPE demo_incident_active gauge",
        f"demo_incident_active {int(w['active'])}",
        "# HELP demo_incident_seconds_remaining Seconds until the open incident window closes.",
        "# TYPE demo_incident_seconds_remaining gauge",
        f"demo_incident_seconds_remaining {w['seconds_remaining']}",
    ]
    return "\n".join(out) + "\n"


def number(query, key, default, low, high):
    """A query parameter as a float within [low, high], else ValueError."""
    if key not in query:
        return default
    value = float(query[key][0])
    if not low <= value <= high:
        raise ValueError(f"{key} must be within {low}..{high}")
    return value


class Handler(BaseHTTPRequestHandler):
    def reply(self, code, body, content_type="application/json"):
        body = body.encode()
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/metrics":
            self.reply(200, exposition(), "text/plain; version=0.0.4; charset=utf-8")
        elif path == "/incident":
            with lock:
                self.reply(200, json.dumps(incident_json(time.time())) + "\n")
        else:
            self.send_error(404)

    def do_POST(self):
        url = urlsplit(self.path)
        if url.path != "/incident":
            self.send_error(404)
            return
        query = parse_qs(url.query)
        try:
            seconds = number(query, "seconds", INCIDENT_DURATION, 1, 86400)
            error_ratio = number(query, "errorRatio", INCIDENT_ERROR_RATIO, 0, 1)
            latency_factor = number(query, "latencyFactor", INCIDENT_LATENCY_FACTOR, 1, 100)
        except ValueError as exc:
            self.reply(400, json.dumps({"error": str(exc)}) + "\n")
            return
        now = time.time()
        with lock:
            manual.update({"until": now + seconds, "errorRatio": error_ratio, "latencyFactor": latency_factor})
            state = incident_json(now)
        print(f"incident opened on demand for {seconds:g}s: errorRatio {error_ratio:g}, latencyFactor {latency_factor:g}", flush=True)
        self.reply(200, json.dumps(state) + "\n")

    def do_DELETE(self):
        global suppressed_until
        if urlsplit(self.path).path != "/incident":
            self.send_error(404)
            return
        now = time.time()
        with lock:
            w = incident(now)
            # end the on-demand window, then a scheduled one it may have hidden
            manual["until"] = 0.0
            scheduled = incident(now)
            if scheduled["source"] == "schedule":
                suppressed_until = scheduled["until"]
            state = incident_json(now)
        if w["active"]:
            print(f"incident ({w['source']}) ended on demand", flush=True)
        self.reply(200, json.dumps(state) + "\n")

    def log_message(self, *args):  # keep stdout for real events
        pass


if __name__ == "__main__":
    threading.Thread(target=simulate, daemon=True).start()
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
