FROM ruby:3.4.8-alpine AS builder

ARG BUILD_PACKAGES="build-base libxml2 libxslt git"
ARG DEV_PACKAGES="ruby-dev libffi-dev libxml2-dev libxslt-dev yaml-dev postgresql-dev nodejs npm pnpm zlib-dev imagemagick-dev libwebp-dev libpng-dev tiff-dev gcompat"
ARG RUBY_PACKAGES="tzdata"

ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="mirrors.ustc.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com"
ARG NPM_REGISTRY="https://registry.npmmirror.com"
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
      pnpm config set registry $NPM_REGISTRY; \
    fi && \
    gem install $RUBY_GEMS

WORKDIR $APP_ROOT

# Node dependencies
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

# Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle config set path 'vendor/bundle' && \
    bundle lock --add-platform ruby && \
    bundle install --jobs $(nproc) --retry 3

# Platform assertion: no non-musl gem artifact may ship. This replaces
# force_ruby_platform, which hid glibc artifacts by disabling platform
# resolution instead of verifying its result; the script body documents the
# invariant it now enforces (2022 nokogiri incident).
RUN <<'RUBY' bundle exec ruby
# Every gem in the installed bundle must be either the ruby platform (it was
# built/generated locally) or a musl-native variant (*-linux-musl). Anything
# else is a foreign artifact that must not ship: glibc binaries (-gnu) can
# never load on this image, and legacy bare-Linux binaries (e.g. x86_64-linux)
# are glibc-linked yet still match the local platform.
def valid_platform?(platform)
  platform == "ruby" || platform.end_with?("-linux-musl")
end

def platform_check_offenders(specs)
  specs.reject { |spec| valid_platform?(spec.platform.to_s) }
       .map { |spec| "#{spec.name} #{spec.version} #{spec.platform}" }
end

specs = Bundler.load.specs
offenders = platform_check_offenders(specs)

if offenders.empty?
  puts "Platform assertion passed: #{specs.size} specs installed, all ruby or *-linux-musl"
else
  warn "Platform assertion FAILED: #{offenders.size} gem(s) are neither ruby nor musl platform:"
  offenders.sort.each { |offender| warn "  #{offender}" }
  exit 1
end
RUBY

COPY . $APP_ROOT
RUN SECRET_KEY_BASE=precompile_placeholder bin/rails vite:build

# Remove folders not needed in resulting image
RUN rm -rf docker node_modules tmp/cache spec .browserslistrc babel.config.js \
    package.json postcss.config.js pnpm-lock.yaml && \
    cd /app/vendor/bundle/ruby/3.4.0 && \
      rm -rf cache/*.gem && \
      find gems/ -name "*.c" -delete && \
      find gems/ -name "*.o" -delete

##################################################################################

FROM ruby:3.4.8-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG TAG
ARG ZEALOT_VERSION

ARG REPLACE_CHINA_MIRROR="true"
ARG ORIGINAL_REPO_URL="dl-cdn.alpinelinux.org"
ARG MIRROR_REPO_URL="mirrors.ustc.edu.cn"
ARG RUBYGEMS_SOURCE="https://gems.ruby-china.com/"
ARG PACKAGES="tzdata curl logrotate postgresql-client postgresql-dev imagemagick imagemagick-dev libwebp-dev libpng-dev tiff-dev openssl openssl-dev caddy gcompat"
ARG RUBY_GEMS="bundler"
ARG APP_ROOT=/app
ARG S6_OVERLAY_VERSION="2.2.0.3"
ARG TARGETARCH

ENV TZ="Asia/Shanghai" \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    DOCKER_TAG="$TAG" \
    BUNDLE_APP_CONFIG="$APP_ROOT/.bundle" \
    ZEALOT_VCS_REF="$VCS_REF" \
    ZEALOT_BUILD_DATE="$BUILD_DATE" \
    RAILS_ENV="production" \
    RUBY_YJIT_ENABLE="true"

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
    *) \
        echo "Doesn't support $TARGETARCH architecture" \
        exit 1 \
    ;; \
    esac && \
    curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz | tar xvzf - -C /

WORKDIR $APP_ROOT

COPY docker/rootfs /
COPY --from=builder $APP_ROOT $APP_ROOT

# Native-extension smoke: prove the delivered runtime stage's shared libraries
# are complete. It must run here, not in the builder -- the two stages install
# different system packages, and only this stage reflects the shipped image.
RUN bundle exec ruby -e 'require "nokogiri"; require "pg"; require "google/protobuf"; require "ffi"; puts "Native extension smoke passed: nokogiri, pg, google-protobuf, ffi"'

RUN ln -s /app/bin/rails /usr/local/bin/

EXPOSE 80

# VOLUME [ "/app/public/uploads", "/app/public/backup" ]

ENTRYPOINT ["/init"]
