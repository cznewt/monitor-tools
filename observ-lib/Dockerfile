# observ-lib — render Grafana v2 dashboards from Jsonnet manifests.
# Built here (monitor-tools) from the public observ-viz sources; the library
# lands at /observ-viz on the jpath, so consumer manifests can
# `import 'g.libsonnet'` without vendoring. Rebuild via workflow_dispatch or
# the weekly cron to pick up observ-viz changes (this repo has no path
# trigger for them).
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates bash git \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir jsonnet pyyaml requests

# jsonnet-bundler (jb), for consumers that vendor additional deps
ARG JB_VERSION=v0.6.0
RUN curl -fsSL -o /usr/local/bin/jb \
      "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/${JB_VERSION}/jb-linux-amd64" \
 && chmod +x /usr/local/bin/jb

ARG OBSERV_VIZ_REF=main
ENV OBSERV_VIZ_HOME=/observ-viz
RUN git clone --depth 1 --branch "${OBSERV_VIZ_REF}" https://github.com/cznewt/observ-viz /observ-viz \
 && chmod +x /observ-viz/docker/entrypoint.sh \
 && rm -rf /observ-viz/.git

WORKDIR /work
ENTRYPOINT ["/observ-viz/docker/entrypoint.sh"]
CMD ["help"]
