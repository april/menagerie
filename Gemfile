source "https://rubygems.org"
ruby "2.4.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.3'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem "bcrypt", "~> 3.1"
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem "dotenv-rails"
gem "will_paginate"
gem "typhoeus"
gem "engtagger"


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# TEST SUITE GEMS
group :test do
  gem "minitest", "~> 5.10"            # Native Ruby testing framework
end

# PRODUCTION-ONLY GEMS
group :production do
  gem "rails_12factor"                 # Heroku 12-factor app support
end