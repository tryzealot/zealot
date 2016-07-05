FROM ruby:2.2.5-alpine
MAINTAINER icyleaf.cn@gmail.com

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base libxml2" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev" \
    RUBY_PACKAGES="yaml nodejs" \
    RUBY_GEMS="bundler" \
    APK_MAIN_REPO="http://dl-cdn.alpinelinux.org/alpine/v3.4/main" \
    APK_COMMUNITY_REPO="http://dl-cdn.alpinelinux.org/alpine/v3.4/community"
# #    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev mysql-dev sqlite-dev postgresql-dev"
#

RUN echo $APK_MAIN_REPO > /etc/apk/repositories && \
    echo $APK_COMMUNITY_REPO >> /etc/apk/repositories

# RUN apk --update add $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
#     gem install -N $RUBY_GEMS
#
# WORKDIR /APP
# ADD Gemfile .
# RUN bundle config --global build.nokogiri --use-system-libraries && \
#     bundle install nokogiri && \
#     bundle install --jobs 20 --retry 5
# ADD . /APP
#
# CMD ['bundle exec foreman start -f Procfile.dev']

# CMD ['/bin/sh']