FROM ghcr.io/cznewt/monitor-tools:latest


COPY ./files/requirements.txt /requirements-notebook.txt

USER root

RUN curl -fSL -o "jsonnet-language-server" "https://github.com/grafana/jsonnet-language-server/releases/download/v0.16.0/jsonnet-language-server_0.16.0_linux_amd64" && \
    chmod a+x "jsonnet-language-server" && \
    mv "jsonnet-language-server" "/usr/local/bin/jsonnet-language-server"

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

RUN npm i -g bash-language-server && \
    npm i -g yaml-language-server && \
    npm i -g vscode-json-languageserver-bin

COPY ./files/jupyter /home/ubuntu/.jupyter

RUN chown ubuntu:ubuntu /home/ubuntu/.jupyter -R

RUN uv pip install --system --break-system-packages --no-cache-dir -r /requirements-notebook.txt

USER ubuntu

RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

EXPOSE 8888

CMD ["jupyter", "lab", "--config=/home/ubuntu/.jupyter/jupyter_notebook_config.py"]
