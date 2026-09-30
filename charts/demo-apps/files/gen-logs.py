"""Emit JSON access-log lines of a simulated storefront service on stdout.

One line per simulated HTTP request: level, method, route, status, latency_ms
and a trace_id - enough for LogQL exercises (the json parser, rate by status,
error ratio, top routes, latency quantiles with unwrap). Every
INCIDENT_EVERY_SECONDS an incident window of INCIDENT_DURATION_SECONDS raises
the error ratio and the latency, so log-based alerts have something to fire on.
Collected like any pod's stdout (Alloy pod logs -> Loki).
"""
import json
import os
import random
import secrets
import sys
import time

SERVICE = os.environ.get("SERVICE_NAME", "storefront")
NAMESPACE = os.environ.get("SERVICE_NAMESPACE", "onlinestore")
ENVIRONMENT = os.environ.get("DEPLOYMENT_ENVIRONMENT", "workshop")
RATE = float(os.environ.get("RATE_PER_SECOND", "2"))
ERROR_RATIO = float(os.environ.get("ERROR_RATIO", "0.05"))
INCIDENT_EVERY = float(os.environ.get("INCIDENT_EVERY_SECONDS", "1800"))
INCIDENT_DURATION = float(os.environ.get("INCIDENT_DURATION_SECONDS", "300"))
INCIDENT_ERROR_RATIO = float(os.environ.get("INCIDENT_ERROR_RATIO", "0.5"))
INCIDENT_LATENCY_FACTOR = float(os.environ.get("INCIDENT_LATENCY_FACTOR", "5"))

# method, route, weight, median latency (ms)
ROUTES = [
    ("GET", "/", 30, 15),
    ("GET", "/products", 25, 40),
    ("GET", "/products/{id}", 20, 25),
    ("POST", "/cart", 10, 60),
    ("POST", "/cart/checkout", 8, 180),
    ("GET", "/health", 7, 2),
]
CLIENT_ERRORS = [(400, "invalid request"), (401, "missing session"), (404, "product not found"), (409, "cart changed")]
SERVER_ERRORS = [(500, "unhandled exception"), (502, "payments upstream failed"), (503, "inventory unavailable"), (504, "checkout timed out")]


def in_incident(now):
    return INCIDENT_EVERY > 0 and (now % INCIDENT_EVERY) < INCIDENT_DURATION


def one_line(now):
    method, route, _, median = random.choices(ROUTES, weights=[r[2] for r in ROUTES])[0]
    incident = in_incident(now)
    error_ratio = INCIDENT_ERROR_RATIO if incident else ERROR_RATIO
    latency = max(1.0, random.lognormvariate(0, 0.4) * median * (INCIDENT_LATENCY_FACTOR if incident else 1))
    roll = random.random()
    if roll < error_ratio:
        status, msg = random.choice(SERVER_ERRORS)
        level = "error"
    elif roll < error_ratio + 0.04:
        status, msg = random.choice(CLIENT_ERRORS)
        level = "warn"
    else:
        status = 201 if method == "POST" else 200
        level, msg = "info", "request served"
    return {
        "ts": time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime(now)) + f".{int(now % 1 * 1000):03d}Z",
        "level": level,
        "service": SERVICE,
        "service_namespace": NAMESPACE,
        "environment": ENVIRONMENT,
        "method": method,
        "route": route,
        "status": status,
        "latency_ms": round(latency, 1),
        "trace_id": secrets.token_hex(16),
        "incident": incident,
        "msg": msg,
    }


def main():
    mean_gap = 1.0 / RATE if RATE > 0 else 1.0
    while True:
        sys.stdout.write(json.dumps(one_line(time.time())) + "\n")
        sys.stdout.flush()
        time.sleep(random.uniform(0.5, 1.5) * mean_gap)


if __name__ == "__main__":
    main()
