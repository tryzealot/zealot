FROM ruby:2.6-alpine as builder

ARG BUILD_PACKAGES="build-base libxml2 libxslt git"
ARG DEV_PACKAGES="libxml2-dev libxslt-dev yaml-dev imagemagick-dev postgresql-dev nodejs npm yarn"
ARG RUBY_PACKAGES="tzdata"

ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="http://dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="https://mirrors.tuna.tsinghua.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG NPM_REGISTRY="https://registry.npm.taobao.org"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT="/app"

ENV BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    RAILS_ENV="production"

# System dependencies
RUN set -ex && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      REPLACE_STRING=$(echo $MIRROR_REPO_URL | sed 's/\//\\\//g') && \
      SEARCH_STRING=$(echo $ORIGINAL_REPO_URL | sed 's/\//\\\//g') && \
      sed -i "s/$SEARCH_STRING/$REPLACE_STRING/g" /etc/apk/repositories && \
      gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/ && \
      bundle config mirror.https://rubygems.org $RUBYGEMS_SOURCE; \
    fi && \
    apk --update --no-cache add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      yarn config set registry $NPM_REGISTRY; \
    fi && \
    gem install $RUBY_GEMS

WORKDIR $APP_ROOT

# Node dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --path=vendor/bundle --without development test \
      --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

COPY . $APP_ROOT
RUN SECRET_TOKEN=precompile_placeholder bin/rails assets:precompile && \
    cp -r public/ new_public/

# Remove folders not needed in resulting image
RUN rm -rf docker node_modules tmp/cache spec .browserslistrc babel.config.js \
    package.json postcss.config.js yarn.lock

##################################################################################

FROM ruby:2.6-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG TAG

ARG ZEALOT_VERSION="4.0.0.beta4"
ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="http://dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="https://mirrors.tuna.tsinghua.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG PACKAGES="tzdata curl shadow logrotate imagemagick imagemagick-dev postgresql-dev postgresql-client openssl openssl-dev"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT=/app
ARG S6_OVERLAY_VERSION="2.0.0.1"

LABEL im.ews.zealot.build-date=$BUILD_DATE \
      im.ews.zealot.vcs-ref=$VCS_REF \
      im.ews.zealot.version="$ZEALOT_VERSION-$TAG" \
      im.ews.zealot.name="Zealot" \
      im.ews.zealot.description="Over The Air Server for deployment of Android and iOS apps" \
      im.ews.zealot.url="https://zealot.ews.im/" \
      im.ews.zealot.vcs-url="https://github.com/getzealot/zealot" \
      im.ews.zealot.maintaner="icyleaf <icyleaf.cn@gmail.com>"

ENV TZ="Asia/Shanghai" \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    DOCKER_TAG="$TAG" \
    BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    ZEALOT_VCS_REF="$VCS_REF" \
    ZEALOT_VERSION="$ZEALOT_VERSION" \
    RAILS_ENV="production" \
    ENABLE_BOOTSNAP="false"

# System dependencies
RUN set -ex && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      REPLACE_STRING=$(echo $MIRROR_REPO_URL | sed 's/\//\\\//g') && \
      SEARCH_STRING=$(echo $ORIGINAL_REPO_URL | sed 's/\//\\\//g') && \
      sed -i "s/$SEARCH_STRING/$REPLACE_STRING/g" /etc/apk/repositories && \
      gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/; \
    fi && \
    apk --update --no-cache add $PACKAGES && \
    curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xvzf - -C / && \
    gem install $RUBY_GEMS && \
    adduser -D -u 911 -g zealot -h /app -s /sbin/nologin zealot

WORKDIR $APP_ROOT

COPY docker/rootfs /
COPY --from=builder $APP_ROOT $APP_ROOT

EXPOSE 3000

ENTRYPOINT ["/init"]
