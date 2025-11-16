# bundle --without postmark

source "https://rubygems.org"

gem "rails", "~> 6.1.7.3"
gem 'responders'

# TODO: migrate database config and swith to psych >= 4!
gem 'psych', '~> 3.3.4'

gem "mysql2"

# fix cert error with ruby 3.6.0
# https://github.com/ruby/openssl/issues/949
gem 'openssl', '~> 3.3.2'

group :assets do
  gem "sass-rails"
  gem "coffee-rails"
  gem "uglifier"
  gem 'sprockets', '~> 4'
  gem 'sprockets-rails', :require => 'sprockets/railtie'
end

gem "dynamic_form"
gem "haml"
gem "htmlentities"
gem "jquery-rails"

group :postmark do
  gem "postmark-rails"
  gem "postmark"
end

# gem "redis"
# gem "resque", require: "resque/server"
gem 'dotenv'
gem "will_paginate"

gem 'concurrent-ruby', '1.3.4'

group :development do
  gem 'puma'
end

# gem 'listen'