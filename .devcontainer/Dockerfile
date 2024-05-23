# See .devcontainer/Dockerfile.base and .github/workflows/publish_codespace.yml files.
FROM ghcr.io/tryzealot/codespace:latest

COPY . /workspace

USER root
RUN chown -R vscode:vscode /workspace
USER vscode

RUN bundle install && yarn install
