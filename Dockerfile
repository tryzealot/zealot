FROM ruby:2.6-alpine
LABEL MAINTAINER="icyleaf.cn@gmail.com"

ENV BUILD_PACKAGES="build-base libxml2 libxslt libxslt imagemagick tzdata git" \
    DEV_PACKAGES="ruby-dev curl-dev libxml2-dev libxslt-dev imagemagick-dev postgresql-dev" \
    RUBY_PACKAGES="ruby yaml nodejs npm yarn" \
    RUBY_GEMS="bundler" \
    RUBYGEMS_SOURCE="https://gems.ruby-china.com/" \
    ORIGINAL_REPO_URL="http://dl-cdn.alpinelinux.org" \
    MIRROR_REPO_URL="https://mirrors.tuna.tsinghua.edu.cn" \
    NPM_REGISTRY="https://registry.npm.taobao.org" \
    TZ="Asia/Shanghai" \
    RAILS_ENV="production"

RUN set -ex && \
    REPLACE_STRING=$(echo $MIRROR_REPO_URL | sed 's/\//\\\//g') && \
    SEARCH_STRING=$(echo $ORIGINAL_REPO_URL | sed 's/\//\\\//g') && \
    sed -i "s/$SEARCH_STRING/$REPLACE_STRING/g" /etc/apk/repositories && \
    apk --update --no-cache add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/ && \
    gem install $RUBY_GEMS

WORKDIR /app
COPY Gemfile Gemfile.lock package.json yarn.lock ./

RUN mkdir -p /app/pids && \
    bundle install --binstubs --deployment --without development test --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 3

RUN yarn install

ENV S6_OVERLAY_VERSION=1.22.1.0
RUN apk add --update --no-cache curl redis postgresql-client postgresql-libs && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C / && \
    apk del --no-cache curl

EXPOSE 80

COPY . .

COPY docker/root /

ENTRYPOINT [ "/init" ]
