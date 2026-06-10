# Prophet-based anomaly scorer
#
# Polls a Prometheus-compatible API for a range query, fits a Prophet model per
# returned series, scores how far the trailing points fall outside the predicted
# uncertainty band, and re-exports the worst-point score per series as a
# Prometheus gauge (default: custom_anomaly_score). Every knob is an env var;
# see README.md.
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# libgomp1: OpenMP runtime required by Prophet's bundled Stan model.
RUN apt-get update \
    && apt-get install --no-install-recommends -y libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY files/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY files/anomaly_scorer.py /app/anomaly_scorer.py

# In-cluster defaults; override any of these at run time (see README).
ENV PROMETHEUS_URL="http://prometheus-operated.monitoring.svc:9090" \
    METRIC_QUERY="container_memory_working_set_bytes{namespace=\"production\"}" \
    ANOMALY_LABELS="namespace,pod" \
    LOOKBACK_DAYS="7" \
    STEP="5m" \
    EVAL_POINTS="12" \
    INTERVAL_WIDTH="0.95" \
    DAILY_SEASONALITY="true" \
    WEEKLY_SEASONALITY="auto" \
    LOOP_INTERVAL="300" \
    EXPORTER_PORT="8000" \
    METRIC_NAME="custom_anomaly_score"

EXPOSE 8000

RUN useradd --create-home --uid 10001 scorer
USER scorer

ENTRYPOINT ["python", "/app/anomaly_scorer.py"]
