source 'https://rubygems.org'

gem 'rails', '4.1.6'
gem 'sqlite3'
gem 'hydra-head', '~> 7.2.1'
gem 'blacklight', '~> 5.7.1'
gem 'active-fedora', '~> 7.1.1'
gem 'hydra-editor', '~> 0.5.0'

# production and deployment gems
gem 'mysql2'
gem 'therubyracer',  platforms: :ruby
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'nprogress-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'tufts_models', github: 'curationexperts/tufts_models', ref: 'v4.0.0.rc4'

gem "devise"
gem "devise-guests", "~> 0.3"
gem 'blacklight-gallery', '~> 0.1.0'
gem 'settingslogic' # for settings

gem 'breadcrumbs_on_rails', '~> 2.3.0'


group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem "jettywrapper"
  gem "unicorn"
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
end

group :debug do
  gem 'byebug', require: false
  gem 'launchy'
end
