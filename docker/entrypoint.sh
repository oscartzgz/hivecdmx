#!/bin/bash
set -e

# Remove server.pid if it exists from a previous run
rm -f /rails/tmp/pids/server.pid

# Run pending migrations
bundle exec rails db:migrate 2>/dev/null || true

exec "$@"
