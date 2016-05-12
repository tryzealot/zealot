FROM ruby:2.2.5-alpine
MAINTAINER icyleaf.cn@gmail.com

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev" \
    RUBY_PACKAGES="yaml nodejs"
# #    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev sqlite-dev postgresql-dev"
#
RUN apk --update add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

WORKDIR /APP
ADD Gemfile .
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs 20 --retry 5
ADD . /APP
