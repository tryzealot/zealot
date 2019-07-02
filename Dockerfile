FROM ruby:2.5-alpine
LABEL MAINTAINER="icyleaf.cn@gmail.com"

ENV BUILD_PACKAGES="build-base libxml2 libxslt libxslt imagemagick tzdata git" \
    DEV_PACKAGES="ruby-dev curl-dev libxml2-dev libxslt-dev imagemagick-dev mysql-dev" \
    RUBY_PACKAGES="ruby yaml nodejs yarn" \
    RUBY_GEMS="bundler" \
    RUBYGEMS_SOURCE="https://gems.ruby-china.com/" \
    ORIGINAL_REPO_URL="http://dl-cdn.alpinelinux.org" \
    MIRROR_REPO_URL="https://mirrors.tuna.tsinghua.edu.cn" \
    NPM_REGISTRY="https://registry.npm.taobao.org" \
    TZ="Asia/Shanghai"

RUN REPLACE_STRING=$(echo $MIRROR_REPO_URL | sed 's/\//\\\//g') && \
    SEARCH_STRING=$(echo $ORIGINAL_REPO_URL | sed 's/\//\\\//g') && \
    sed -i "s/$SEARCH_STRING/$REPLACE_STRING/g" /etc/apk/repositories && \
    apk --update --no-cache add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    yarn config set registry $NPM_REGISTRY && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    gem sources --add $RUBYGEMS_SOURCE --remove https://rubygems.org/ && \
    gem install $RUBY_GEMS

WORKDIR /app
COPY Gemfile Gemfile.lock package.json ./

RUN bundle install --binstubs && \
    mkdir -p /var/lib/app/pids && \
    yarn

ADD . .

EXPOSE 3000

CMD [ "bundle", "exec", "puma", "-c", "config/puma.rb" ]