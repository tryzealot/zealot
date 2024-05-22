# See .devcontainer/Dockerfile.base and .github/workflows/publish_codespace.yml files.
FROM ghcr.io/tryzealot/codespace:latest

COPY . /workspace
RUN bundle install && yarn install
