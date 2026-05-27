# Dockerfile
FROM ruby:3.4-slim AS base

RUN apt-get update -qq && apt-get install -y \
  build-essential libpq-dev nodejs postgresql-client curl git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /rails
ENV BUNDLE_PATH=/bundle BUNDLE_BIN=/bundle/bin GEM_HOME=/bundle

# --- Build stage ---
FROM base AS build
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# --- Production stage ---
FROM base AS production

COPY --from=build /bundle /bundle
COPY --from=build /rails /rails

RUN useradd -m rails && chown -R rails:rails /rails
USER rails

COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
