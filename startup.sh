#!/bin/bash

set -x  

# gem install foreman
# gem install mysql2

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails runner "Message.reindex"

foreman start