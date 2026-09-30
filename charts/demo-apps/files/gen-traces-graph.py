"""Emit one three-service checkout trace per tick, as OTLP/HTTP JSON.

Every trace carries the client/server pairs a real distributed call would:
  storefront  SERVER  GET /cart/checkout
    storefront  CLIENT  POST /checkout      peer.service=checkout
      checkout  SERVER  POST /checkout
        checkout  CLIENT  POST /charge      peer.service=payments
          payments  SERVER  POST /charge
Tempo's service-graphs processor turns each pair into an edge, which is what
the RED / Service graph board reads (traces_service_graph_request_total).
Incident windows (the INCIDENT_* schedule, or with INCIDENT_URL set the
release's incident switch - the metrics generator's GET /incident, polled
every INCIDENT_POLL_SECONDS) raise the share of failed traces to the window's
error ratio and stretch every span by its latency factor; the storefront
server span carries demo.incident=true meanwhile.
"""
import json
import os
import random
import threading
import time
import urllib.error
import urllib.request

ENDPOINT = os.environ.get("OTLP_HTTP_ENDPOINT", "http://tempo-monolith.global-monitor-tempo.svc:4318/v1/traces")
TENANT = os.environ.get("TENANT", "anonymous")
INTERVAL = float(os.environ.get("INTERVAL_SECONDS", "2"))
ERROR_RATIO = float(os.environ.get("ERROR_RATIO", "0.08"))
NAMESPACE = os.environ.get("SERVICE_NAMESPACE", "onlinestore")
ENVIRONMENT = os.environ.get("DEPLOYMENT_ENVIRONMENT", "workshop")
INCIDENT_EVERY = float(os.environ.get("INCIDENT_EVERY_SECONDS", "0"))
INCIDENT_DURATION = float(os.environ.get("INCIDENT_DURATION_SECONDS", "300"))
INCIDENT_ERROR_RATIO = float(os.environ.get("INCIDENT_ERROR_RATIO", "0.5"))
INCIDENT_LATENCY_FACTOR = float(os.environ.get("INCIDENT_LATENCY_FACTOR", "5"))
INCIDENT_URL = os.environ.get("INCIDENT_URL", "")
INCIDENT_POLL = float(os.environ.get("INCIDENT_POLL_SECONDS", "5"))

SERVER, CLIENT = 2, 3  # OTLP SpanKind
STATUS_OK, STATUS_ERROR = 1, 2
followed = {"state": None}


def local_window(now):
    """The scheduled window, computed from the clock like the metrics generator does."""
    if INCIDENT_EVERY > 0 and (now % INCIDENT_EVERY) < INCIDENT_DURATION:
        return {"active": True, "errorRatio": INCIDENT_ERROR_RATIO, "latencyFactor": INCIDENT_LATENCY_FACTOR}
    return {"active": False, "errorRatio": ERROR_RATIO, "latencyFactor": 1.0}


def follow():
    """Poll the incident switch (the metrics generator); None while it cannot be reached."""
    while True:
        try:
            with urllib.request.urlopen(INCIDENT_URL, timeout=3) as resp:
                followed["state"] = json.load(resp)
        except Exception:  # noqa: BLE001 - fall back to the local schedule
            followed["state"] = None
        time.sleep(INCIDENT_POLL)


def window(now):
    """The incident window in force: the switch's when it answers, else the schedule."""
    state = followed["state"]
    if state is None:
        return local_window(now)
    if state.get("active") and now < state.get("until", 0):
        return {"active": True, "errorRatio": float(state["errorRatio"]), "latencyFactor": float(state["latencyFactor"])}
    return {"active": False, "errorRatio": ERROR_RATIO, "latencyFactor": 1.0}

def hexid(nbytes):
    return "%0*x" % (nbytes * 2, random.getrandbits(nbytes * 8))


def attrs(pairs):
    out = []
    for key, value in pairs.items():
        if isinstance(value, bool):
            out.append({"key": key, "value": {"boolValue": value}})
        elif isinstance(value, int):
            out.append({"key": key, "value": {"intValue": str(value)}})
        elif isinstance(value, float):
            out.append({"key": key, "value": {"doubleValue": value}})
        else:
            out.append({"key": key, "value": {"stringValue": str(value)}})
    return out


def span(name, kind, trace_id, span_id, parent_id, start_ns, duration_ns, extra=None, failed=False):
    s = {
        "traceId": trace_id,
        "spanId": span_id,
        "name": name,
        "kind": kind,
        "startTimeUnixNano": str(start_ns),
        "endTimeUnixNano": str(start_ns + duration_ns),
        "attributes": attrs(extra or {}),
        "status": {"code": STATUS_ERROR, "message": "payment declined"} if failed else {"code": STATUS_OK},
    }
    if parent_id:
        s["parentSpanId"] = parent_id
    return s


def resource_spans(service, spans):
    return {
        "resource": {"attributes": attrs({
            "service.name": service,
            "service.namespace": NAMESPACE,
            "deployment.environment": ENVIRONMENT,
            "telemetry.sdk.language": "python",
        })},
        "scopeSpans": [{"scope": {"name": "demo.service-graph"}, "spans": spans}],
    }


def one_trace():
    trace_id = hexid(16)
    ids = [hexid(8) for _ in range(5)]
    w = window(time.time())
    failed = random.random() < w["errorRatio"]
    ms = 1_000_000
    now = int(time.time() * 1e9)
    # nested durations: the caller always outlives the callee
    def stretch(low, high):
        return int(random.randint(low, high) * ms * w["latencyFactor"])
    d_pay = stretch(15, 120)
    d_pay_client = d_pay + stretch(1, 8)
    d_checkout = d_pay_client + stretch(5, 40)
    d_front_client = d_checkout + stretch(1, 8)
    d_front = d_front_client + stretch(5, 30)
    route = random.choice(["/cart/checkout", "/cart/checkout?express=1"])
    cart = "cart-" + hexid(4)
    front = [
        span("GET " + route, SERVER, trace_id, ids[0], None, now, d_front,
             {"http.request.method": "GET", "url.path": route, "cart.id": cart,
              "http.response.status_code": 500 if failed else 200, "demo.incident": w["active"]}, failed),
        span("POST /checkout", CLIENT, trace_id, ids[1], ids[0], now + 4 * ms, d_front_client,
             {"peer.service": "checkout", "server.address": "checkout.onlinestore.svc",
              "http.request.method": "POST", "http.response.status_code": 500 if failed else 200}, failed),
    ]
    checkout = [
        span("POST /checkout", SERVER, trace_id, ids[2], ids[1], now + 6 * ms, d_checkout,
             {"http.request.method": "POST", "url.path": "/checkout", "cart.id": cart,
              "http.response.status_code": 500 if failed else 200}, failed),
        span("POST /charge", CLIENT, trace_id, ids[3], ids[2], now + 12 * ms, d_pay_client,
             {"peer.service": "payments", "server.address": "payments.onlinestore.svc",
              "http.request.method": "POST", "http.response.status_code": 402 if failed else 200}, failed),
    ]
    payments = [
        span("POST /charge", SERVER, trace_id, ids[4], ids[3], now + 14 * ms, d_pay,
             {"http.request.method": "POST", "url.path": "/charge",
              "payment.method": random.choice(["card", "paypal", "apple_pay"]),
              "payment.amount": round(random.uniform(5.0, 500.0), 2),
              "http.response.status_code": 402 if failed else 200}, failed),
    ]
    return {"resourceSpans": [
        resource_spans("storefront", front),
        resource_spans("checkout", checkout),
        resource_spans("payments", payments),
    ]}


def main():
    if INCIDENT_URL:
        threading.Thread(target=follow, daemon=True).start()
    sent = failed_sends = 0
    while True:
        body = json.dumps(one_trace()).encode()
        req = urllib.request.Request(ENDPOINT, data=body, method="POST")
        req.add_header("Content-Type", "application/json")
        req.add_header("X-Scope-OrgID", TENANT)
        try:
            with urllib.request.urlopen(req, timeout=10):
                sent += 1
        except Exception as exc:  # keep generating through a Tempo restart
            failed_sends += 1
            if failed_sends % 10 == 1:
                print("send failed: %s" % exc, flush=True)
        if sent and sent % 30 == 0:
            print("traces sent: %d (failed: %d)" % (sent, failed_sends), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
