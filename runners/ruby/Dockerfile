# syntax=docker/dockerfile:1
# Hardened Ruby runner. compose.yaml adds the rest of the sandbox: read-only
# root FS, tmpfs /tmp, no capabilities, no-new-privileges, an internal-only
# network, and memory/CPU/PID caps.
ARG RUBY_VERSION=3.4.7

FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV BUNDLE_DEPLOYMENT=1 BUNDLE_WITHOUT=development:test
COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf /usr/local/bundle/cache

# No compiler or package manager caches in the final image.
FROM docker.io/library/ruby:${RUBY_VERSION}-slim
WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . /app
RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin runner && \
    chmod -R a-w /app
ENV DOJO_SANDBOXED=1 BUNDLE_DEPLOYMENT=1 BUNDLE_WITHOUT=development:test
USER 10001:10001
EXPOSE 9292
CMD ["bundle", "exec", "puma", "--bind", "tcp://0.0.0.0:9292", "--threads", "2:2", "config.ru"]
