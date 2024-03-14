FROM ruby:3.0-alpine as builder

ARG BUILD_PACKAGES="build-base libxml2 libxslt git"
ARG DEV_PACKAGES="libxml2-dev libxslt-dev yaml-dev postgresql-dev nodejs npm yarn imagemagick-dev libwebp-dev libpng-dev tiff-dev gcompat"
ARG RUBY_PACKAGES="tzdata"

ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="mirrors.ustc.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG NPM_REGISTRY="https://registry.npm.taobao.org"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT="/app"

ENV BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    RAILS_ENV="production" \
    RUBY_YJIT_ENABLE="true"

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

WORKDIR $APP_ROOT

# Node dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle config set path 'vendor/bundle' && \
    bundle lock --add-platform ruby && \
    bundle config set force_ruby_platform true && \
    bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

COPY . $APP_ROOT
RUN SECRET_TOKEN=precompile_placeholder bin/rails assets:precompile

# Remove folders not needed in resulting image
RUN rm -rf docker node_modules tmp/cache spec .browserslistrc babel.config.js \
    package.json postcss.config.js yarn.lock && \
    cd /app/vendor/bundle/ruby/3.0.0 && \
      rm -rf cache/*.gem && \
      find gems/ -name "*.c" -delete && \
      find gems/ -name "*.o" -delete

##################################################################################

FROM ruby:3.0-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG TAG

ARG ZEALOT_VERSION="5.2.0"
ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="mirrors.ustc.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG PACKAGES="tzdata curl logrotate postgresql-client postgresql-dev imagemagick imagemagick-dev libwebp-dev libpng-dev tiff-dev openssl openssl-dev caddy gcompat"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT=/app
ARG S6_OVERLAY_VERSION="2.2.0.3"
ARG TARGETARCH

LABEL org.opencontainers.image.title="Zealot" \
      org.opencontainers.image.description="Over The Air Server for deployment of Android and iOS apps" \
      org.opencontainers.image.url="https://zealot.ews.im/" \
      org.opencontainers.image.authors="icyleaf <icyleaf.cn@gmail.com>" \
      org.opencontainers.image.source="https://github.com/tryzealot/zealot" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$ZEALOT_VERSION

ENV TZ="Asia/Shanghai" \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    DOCKER_TAG="$TAG" \
    BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    ZEALOT_VCS_REF="$VCS_REF" \
    ZEALOT_VERSION="$ZEALOT_VERSION" \
    ZEALOT_BUILD_DATE="$BUILD_DATE" \
    RAILS_ENV="production"

# System dependencies
RUN set -ex && \
    if [[ "$REPLACE_CHINA_MIRROR" == "true" ]]; then \
      sed -i "s/$ORIGINAL_REPO_URL/$MIRROR_REPO_URL/g" /etc/apk/repositories && \
      gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/; \
    fi && \
    apk --update --no-cache add $PACKAGES && \
    gem install $RUBY_GEMS && \
    echo "Setting variables for ${TARGETARCH}" && \
    case "$TARGETARCH" in \
    "amd64") \
      S6_OVERLAY_ARCH="amd64" \
    ;; \
    "arm64") \
      S6_OVERLAY_ARCH="aarch64" \
    ;; \
    "linux/arm/v7" | "arm") \
      S6_OVERLAY_ARCH="arm" \
    ;; \
    *) \
        echo "Doesn't support $TARGETARCH architecture" \
        exit 1 \
    ;; \
    esac && \
    curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz | tar xvzf - -C /

WORKDIR $APP_ROOT

COPY docker/rootfs /
COPY --from=builder $APP_ROOT $APP_ROOT

RUN ln -s /app/bin/rails /usr/local/bin/

EXPOSE 80

# VOLUME [ "/app/public/uploads", "/app/public/backup" ]

ENTRYPOINT ["/init"]
