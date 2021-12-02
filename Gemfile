source 'https://rubygems.org'

ruby '~> 2.7.4'

# Rails/Core
gem 'rails', '~> 6.0.4' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'bootsnap'
gem 'rack-canonical-host' # Redirect www to root
gem 'webpacker'
gem "image_processing", "~> 1.2"

# Bumped from 4.3.9 for ElasticBeanstalk platform upgrade
gem 'puma', '5.5.2' # Use Puma as the app server
gem 'rack'
gem 'rack-attack'

# Database/Data
gem 'pg'
gem 'after_party' # load data after deploy
gem 'auto_strip_attributes', '~> 2.5'
gem 'closed_struct'

# Dashboard analytics
gem 'energy-sparks_analytics', git: 'https://github.com/Energy-Sparks/energy-sparks_analytics.git', tag: '1.28.0'
# gem 'energy-sparks_analytics', git: 'https://github.com/Energy-Sparks/energy-sparks_analytics.git', branch: 'management-dashboard-summary-table-v2'
# gem 'energy-sparks_analytics', path: '../energy-sparks_analytics'

# Using master due to it having a patch which doesn't override Enumerable#sum if it's already defined
# Last proper release does that, causing all kinds of weird behaviour (+ not defined etc)
gem 'statsample', git: 'https://github.com/Energy-Sparks/statsample', tag: '2.1.1-energy-sparks', branch: 'update-gems-and-awesome-print'

# Assets
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'sass-rails'# Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets
gem 'bootstrap4-datetime-picker-rails' # For tempus dominus date picker
gem 'momentjs-rails'

# Pagination
gem 'pagy'

# Geocoding
gem 'geocoder'
gem 'rgeo-geojson'

# AWS S3 api
gem 'aws-sdk-s3'

# Assets for Emails
gem 'bootstrap-email'

# Frontend
gem 'bootstrap', '~> 4.3.0' # Use bootstrap for responsive layout
gem 'simple_form'

# JS Templating
gem 'handlebars_assets'
# Template variables
gem "mustache", "~> 1.0"

# User input
gem 'trix-rails', require: 'trix'

# Auth & Users
gem 'devise' # Use devise for authentication
gem 'cancancan', '~> 3.0.1' # Use cancancan for authorization

# Utils
gem 'groupdate', '4.0.1' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Bundle update installs 0.7.0 for some weird reason!
gem 'dotenv-rails', '~> 2.7.4' # Shim to load environment variables from .env into ENV in development.
gem 'friendly_id'

# Sitemap
gem 'sitemap_generator'

# For SMS notifications
gem 'twilio-ruby'

# Reduce log noise in dev and test
gem 'lograge'

# Exception handling
gem 'rollbar'
gem 'oj'

# Email service
gem 'mailgun_rails'
gem 'MailchimpMarketing'

# Eventbrite for training page
gem 'eventbrite_sdk'

gem 'wisper', '2.0.0'
gem 'stateful_enum', '0.6.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem "bullet", require: false # use bullet to optimise queries
  gem 'rspec-rails', '~> 4.0.1'
  gem 'rails-controller-testing'
  gem "fakefs", require: "fakefs/safe"
  gem 'factory_bot_rails'
  gem 'climate_control'
  gem 'webmock'
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'terminal-notifier', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'rb-readline', require: false
  gem 'rubocop', '0.90.0'
  gem 'rubocop-rails', '2.8.0'
  gem 'rubocop-performance', '1.8.0'
  gem 'rubocop-rspec'
  gem 'wisper-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'annotate'
  gem 'pry'
  gem 'pry-byebug', '~>3.9.0'
  gem 'overcommit'
  gem 'fasterer'
  gem 'bundler-audit'
  gem 'brakeman'
end

group :test do
  gem 'test-prof'
  gem 'capybara'
  gem 'capybara-email'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'webdrivers'
  gem 'simplecov', :require => false, :group => :test
end
