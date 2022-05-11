# [Choice] Ruby version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.1, 3.0, 2, 2.7, 2.6, 3-bullseye, 3.1-bullseye, 3.0-bullseye, 2-bullseye, 2.7-bullseye, 2.6-bullseye, 3-buster, 3.1-buster, 3.0-buster, 2-buster, 2.7-buster, 2.6-buster
ARG VARIANT=3.0-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/ruby:${VARIANT}

# Update args in docker-compose.yaml to set the UID/GID of the "vscode" user.
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        groupmod --gid $USER_GID vscode \
        && usermod --uid $USER_UID --gid $USER_GID vscode \
        && chmod -R $USER_UID:$USER_GID /home/vscode; \
    fi

# [Option] Install Node.js
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN if [ "${INSTALL_NODE}" = "true" ]; then su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# tmux is for overmind
# TODO : install foreman in future
# packages: postgresql-server-dev-all
# may be postgres in same machine

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
    libssl-dev \
    tar \
    tzdata \
    postgresql-client \
    yarn \
    git \
    imagemagick \
    libjpeg-dev libpng-dev libtiff-dev libwebp-dev \
    tmux \
    zsh

WORKDIR /workspace
COPY . /workspace

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install
