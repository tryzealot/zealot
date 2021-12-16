FROM ruby:2.7-alpine

ARG BUILD_PACKAGES="build-base libxml2 libxslt git"
ARG DEV_PACKAGES="libxml2-dev libxslt-dev yaml-dev postgresql-dev nodejs npm yarn libwebp-dev libpng-dev tiff-dev"
ARG RUBY_PACKAGES="tzdata"

ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="mirrors.ustc.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG NPM_REGISTRY="https://registry.npm.taobao.org"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT="/home/vscode"

ENV BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    RAILS_ENV="development"

# System dependencies
RUN set -ex && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      sed -i "s/$ORIGINAL_REPO_URL/$MIRROR_REPO_URL/g" /etc/apk/repositories && \
      gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/ && \
      bundle config mirror.https://rubygems.org $RUBYGEMS_SOURCE; \
    fi && \
    apk --update --no-cache add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      yarn config set registry $NPM_REGISTRY; \
    fi && \
    gem install $RUBY_GEMS

# Update args in docker-compose.yaml to set the UID/GID of the "vscode" user.
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN addgroup -g $USER_GID vscode && \
    adduser -u $USER_UID -G vscode -D vscode

WORKDIR $APP_ROOT

# Node dependencies
COPY package.json yarn.lock ./
RUN yarn install

# # Ruby dependencies
# COPY Gemfile Gemfile.lock ./
# RUN bundle config set --local path 'vendor/bundle' && \
#     bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

# COPY . $APP_ROOT