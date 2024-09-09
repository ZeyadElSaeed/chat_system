#!/bin/bash

# set -x  

echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
  echo "MySQL is not ready. Sleeping..."
  sleep 10
done
echo "MySQL is up and running!"

# Now proceed with the rest of the 
echo "Creating databases"
bundle exec rails db:create

echo "Migrating database"
bundle exec rails db:migrate

echo "Seeding database"
bundle exec rails db:seed

echo "Reindexing Message model"
bundle exec rails runner "Message.reindex"

echo "Starting app services"
rm /app/tmp/pids/server.pid
foreman start