# Robust (median + MAD) z-score anomaly scorer
#
# Polls a Prometheus-compatible API for a range query, builds a robust
# median + MAD baseline per returned series, scores how many robust sigmas the
# trailing points sit from it, and re-exports the worst-point score per series as
# a Prometheus gauge (default: custom_anomaly_score). Training-free, no Prophet.
# Every knob is an env var; see README.md.
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY files/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY files/anomaly_scorer_zscore.py /app/anomaly_scorer_zscore.py

# In-cluster defaults; override any of these at run time (see README).
ENV PROMETHEUS_URL="http://prometheus-operated.monitoring.svc:9090" \
    METRIC_QUERY="container_memory_working_set_bytes{namespace=\"production\"}" \
    ANOMALY_LABELS="namespace,pod" \
    LOOKBACK_DAYS="7" \
    STEP="5m" \
    EVAL_POINTS="12" \
    Z_MAX="4" \
    LOOP_INTERVAL="300" \
    EXPORTER_PORT="8000" \
    METRIC_NAME="custom_anomaly_score"

EXPOSE 8000

RUN useradd --create-home --uid 10001 scorer
USER scorer

ENTRYPOINT ["python", "/app/anomaly_scorer_zscore.py"]
