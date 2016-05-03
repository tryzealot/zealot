FROM ruby:2.2.5-alpine
MAINTAINER icyleaf.cn@gmail.com

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev mysql-dev" \
    RUBY_PACKAGES="yaml nodejs"

RUN apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES && \
    rm -rf /var/cache/apk/*

WORKDIR /APP
ADD Gemfile .
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs 20 --retry 5
ADD . /APP

# EXPOSE 3000
#
# ENTRYPOINT ["bundle", "exec"]
#
# CMD ["rails", "server", "-b", "0.0.0.0"]
