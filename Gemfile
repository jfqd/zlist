# bundle --without postmark

source "https://rubygems.org"

gem "rails", "~> 3.2.17"

gem 'activerecord-mysql2-adapter'
gem "mysql2", "~> 0.4.10"

group :assets do
  gem "sass-rails"
  gem "coffee-rails"
  gem "uglifier"
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

gem "will_paginate"

group :development do
  gem "quiet_assets"
end

# group :production do
#   gem "thin"
# end
