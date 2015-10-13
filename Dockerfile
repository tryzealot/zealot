FROM ruby:2.2.2
MAINTAINER icyleaf.cn@gmail.com

RUN apt-get update && apt-get install -y \
    build-essential \
    locales \
    nodejs

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app

ADD Gemfile /app/Gemfile
RUN gem install bundler && bundle install --jobs 20 --retry 5
ADD . /app

# COPY Gemfile Gemfile.lock ./
# RUN gem install bundler && bundle install --jobs 20 --retry 5
#
# COPY . ./
#
# EXPOSE 3000
#
# ENTRYPOINT ["bundle", "exec"]
#
# CMD ["rails", "server", "-b", "0.0.0.0"]
