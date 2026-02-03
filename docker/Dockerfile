FROM ubuntu:jammy AS static-downloader

WORKDIR /root

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    git \
    ssh-client \
    wget \
    curl \
    jq \
    unzip \
    ca-certificates \
    gnupg

ARG DEBIAN_FRONTEND=noninteractive
ARG PKG_ARCH=amd64
ENV TZ=Europe/Prague

ARG JUST_VERSION=1.43.0
ENV JUST_VERSION=${JUST_VERSION}
RUN curl -fSL -o "just.tar.gz" "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" && \
    tar xvzf just.tar.gz && \
    chmod a+x "just"

ARG MIMIR_VERSION=3.0.0
ENV MIMIR_VERSION=${MIMIR_VERSION}
RUN curl -fSL -o "mimirtool" "https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/mimirtool-linux-amd64" && \
    chmod a+x "mimirtool"

ARG PROMETHEUS_VERSION=3.7.3
ENV PROMETHEUS_VERSION=${PROMETHEUS_VERSION}
RUN curl -fSL -o "prometheus.tar.gz" "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-${PKG_ARCH}.tar.gz" && \
    tar xvzf prometheus.tar.gz && \
    mv "prometheus-${PROMETHEUS_VERSION}.linux-${PKG_ARCH}/promtool" "promtool"

ARG LOKI_VERSION=3.5.7
ENV LOKI_VERSION=${LOKI_VERSION}
RUN curl -fSL -o "logcli.zip" "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/logcli-linux-${PKG_ARCH}.zip" && \
    unzip "logcli.zip" && \
    mv "logcli-linux-${PKG_ARCH}" "logcli"

ARG ALERTMANAGER_VERSION=0.29.0
ENV ALERTMANAGER_VERSION=${ALERTMANAGER_VERSION}
RUN curl -fSL -o "alertmanager.tar.gz" "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-${PKG_ARCH}.tar.gz" && \
    tar xvzf "alertmanager.tar.gz" && \
    mv "alertmanager-${ALERTMANAGER_VERSION}.linux-${PKG_ARCH}/amtool" "amtool"

ARG SLOTH_VERSION=v0.15.0
ENV SLOTH_VERSION=${SLOTH_VERSION}
RUN curl -fSL -o "sloth" "https://github.com/slok/sloth/releases/download/${SLOTH_VERSION}/sloth-linux-${PKG_ARCH}" && \
    chmod +x "sloth"

ARG PYRRA_VERSION=0.9.0
ENV PYRRA_VERSION=${PYRRA_VERSION}
RUN curl -fSL -o "pyrra.tar.gz" "https://github.com/pyrra-dev/pyrra/releases/download/v${PYRRA_VERSION}/pyrra_${PYRRA_VERSION}_Linux_x86_64.tar.gz" && \
    tar xvzf pyrra.tar.gz && \
    chmod a+x "pyrra"

ARG PINT_VERSION=0.76.1
ENV PINT_VERSION=${PINT_VERSION}
RUN curl -fSL -o "pint.tar.gz" "https://github.com/cloudflare/pint/releases/download/v${PINT_VERSION}/pint-${PINT_VERSION}-linux-${PKG_ARCH}.tar.gz" && \
    tar xvzf "pint.tar.gz" && \
    mv "pint-linux-${PKG_ARCH}" "pint"

ARG GOJSONNET_VERSION=0.21.0
ENV GOJSONNET_VERSION=${GOJSONNET_VERSION}
RUN curl -fSL -o "go-jsonnet.tar.gz" "https://github.com/google/go-jsonnet/releases/download/v${GOJSONNET_VERSION}/go-jsonnet_Linux_x86_64.tar.gz" && \
    tar xvzf "go-jsonnet.tar.gz"

ARG GRR_VERSION=0.7.1
ENV GRR_VERSION=${GRR_VERSION}
RUN curl -fSL -o "grr" "https://github.com/grafana/grizzly/releases/download/v${GRR_VERSION}/grr-linux-amd64" && \
    chmod a+x "grr"

ARG GRAFANACTL_VERSION=0.1.7
ENV GRAFANACTL_VERSION=${GRAFANACTL_VERSION}
RUN curl -fSL -o "grafanactl.tar.gz" "https://github.com/grafana/grafanactl/releases/download/v${GRAFANACTL_VERSION}/grafanactl_Linux_x86_64.tar.gz" && \
    tar xvzf "grafanactl.tar.gz"

ARG VENDIR_VERSION=0.44.0
ENV VENDIR_VERSION=${VENDIR_VERSION}
RUN curl -fSL -o "vendir" "https://github.com/carvel-dev/vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64" && \
    chmod a+x "vendir"

ARG JB_VERSION=0.6.0
ENV JB_VERSION=${JB_VERSION}
RUN curl -fSL -o "jb" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${JB_VERSION}/jb-linux-amd64" && \
    chmod a+x "jb"

ARG JRSONNET_VERSION=0.5.0-pre96-test
ENV JRSONNET_VERSION=${JRSONNET_VERSION}
RUN curl -fSL -o "jrsonnet" "https://github.com/CertainLach/jrsonnet/releases/download/v${JRSONNET_VERSION}/jrsonnet-linux-amd64" && \
    chmod a+x "jrsonnet"

ARG VALE_VERSION=3.13.0
ENV VALE_VERSION=${VALE_VERSION}
RUN curl -fSL -o "vale.tar.gz" "https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz" && \
    tar xvzf vale.tar.gz && \
    chmod a+x "vale"

ARG UV_VERSION=0.9.28
ENV UV_VERSION=${UV_VERSION}
RUN curl -fSL -o "uv.tar.gz" "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" && \
    tar xvzf uv.tar.gz && \
    mv "uv-x86_64-unknown-linux-gnu/uv" "uv" && \
    chmod a+x "uv"

RUN curl -fSL -o "yq" "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" && \
    chmod a+x "yq"

RUN curl -fSL -o "go.linux-amd64.tar.gz" "https://go.dev/dl/go1.25.3.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.linux-amd64.tar.gz

RUN /usr/local/go/bin/go install github.com/grafana/dashboard-linter@latest

RUN /usr/local/go/bin/go install github.com/monitoring-mixins/mixtool/cmd/mixtool@main

FROM ubuntu:24.04

COPY --from=static-downloader /root/grr /usr/local/bin/grr
COPY --from=static-downloader /root/jrsonnet /usr/local/bin/jrsonnet
COPY --from=static-downloader /root/jsonnet /usr/local/bin/jsonnet
COPY --from=static-downloader /root/jsonnetfmt /usr/local/bin/jsonnetfmt
COPY --from=static-downloader /root/mimirtool /usr/local/bin/mimirtool
COPY --from=static-downloader /root/jb /usr/local/bin/jb
COPY --from=static-downloader /root/vendir /usr/local/bin/vendir
COPY --from=static-downloader /root/yq /usr/local/bin/yq
COPY --from=static-downloader /root/sloth /usr/local/bin/sloth
COPY --from=static-downloader /root/logcli /usr/local/bin/logcli
COPY --from=static-downloader /root/pint /usr/local/bin/pint
COPY --from=static-downloader /root/grafanactl /usr/local/bin/grafanactl
COPY --from=static-downloader /root/promtool /usr/local/bin/promtool
COPY --from=static-downloader /root/amtool /usr/local/bin/amtool
COPY --from=static-downloader /root/pyrra /usr/local/bin/pyrra
COPY --from=static-downloader /root/just /usr/local/bin/just
COPY --from=static-downloader /root/go/bin/dashboard-linter /usr/local/bin/dashboard-linter
COPY --from=static-downloader /root/go/bin/mixtool /usr/local/bin/mixtool
COPY --from=static-downloader /root/uv /usr/local/bin/uv
COPY --from=static-downloader /usr/local/go /usr/local/go

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends -y \
    curl \
    ssh-client \
    git \
    wget \
    jq \
    vim \
    netcat-traditional \
    unzip \
    ca-certificates \
    gnupg \
    python3-pip \
    python3-dev \
    pipx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


COPY ./files/requirements.txt /requirements-base.txt
COPY ./files/mixins /mixins
COPY ./files/config /config
COPY ./files/scripts /scripts

RUN mkdir -p /build && \
    mkdir -p /source && \
    chown ubuntu:ubuntu /scripts -R && \
    chown ubuntu:ubuntu /config -R && \
    chown ubuntu:ubuntu /mixins -R && \
    chown ubuntu:ubuntu /build -R && \
    chown ubuntu:ubuntu /source -R 

USER ubuntu

COPY ./files/justfile /source/justfile

WORKDIR /source

RUN uv venv && \
    uv pip install -r /requirements-base.txt

ENV PATH="${PATH}:/usr/local/go/bin:/scripts:/source/.venv/bin:/home/ubuntu/.local/bin"
