FROM ruby:2.3-alpine
MAINTAINER icyleaf.cn@gmail.com

ENV BUILD_PACKAGES="build-base ruby-dev curl-dev libxml2 libxslt libxslt" \
    DEV_PACKAGES="tzdata libxml2-dev libxslt-dev postgresql-dev mysql-dev" \
    RUBY_PACKAGES="yaml nodejs" \
    RUBY_GEMS="bundler" \
    APK_MAIN_REPO="https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.4/main" \
    APK_COMMUNITY_REPO="https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.4/community"

WORKDIR /app
ADD Gemfile /app/ \
    Gemfile.lock /app/

RUN echo $APK_MAIN_REPO > /etc/apk/repositories && \
    echo $APK_COMMUNITY_REPO >> /etc/apk/repositories && \
    apk --update --no-cache add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    gem install -N $RUBY_GEMS && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs 20 --retry 5

ADD . /app

EXPOSE 3000