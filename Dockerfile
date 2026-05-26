FROM ruby:3.4-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  curl \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /rails

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
