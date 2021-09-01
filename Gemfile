# bundle --without postmark

source "https://rubygems.org"

gem "rails", "~> 6.0.4"
gem 'responders'

gem "mysql2"

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

# gem 'listen'