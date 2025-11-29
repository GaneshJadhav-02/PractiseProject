#!/bin/sh
set -e
echo "ENVIRONMENT: $RAILS_ENV"

echo "Installing missing gems"
bundle check || bundle install --jobs 20 --retry 5

echo "Load schema"
bundle exec rails db:schema:load

echo "Removing pre-existing puma server.pid"
rm -f $APP_PATH/tmp/pids/server.pid

# run passed commands
# bundle exec sidekiq -C config/sidekiq.yml &
bundle exec "$@"
