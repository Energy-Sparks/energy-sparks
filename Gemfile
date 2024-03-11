# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 6.1'

# Rails/Core
gem 'bootsnap'
gem 'image_processing', '~> 1.12'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'puma' # Use Puma as the app server
gem 'rack'
gem 'rack-attack'
gem 'rack-canonical-host' # Redirect www to root
gem 'rexml' # ruby 3 related - seems like should be a dependency of bootsnap
gem 'sprockets'
gem 'stateful_enum' # extends ActiveRecord::Enum with state
gem 'webpacker'
gem 'wisper' # publish subscribe for ruby objects

# Database/Data
gem 'after_party' # load data after deploy
gem 'auto_strip_attributes', '~> 2.5'
gem 'closed_struct'
gem 'pg'
gem 'scenic'

# Dashboard analytics
gem 'energy-sparks_analytics', github: 'Energy-Sparks/energy-sparks_analytics', tag: '5.1.3'
# gem 'energy-sparks_analytics', path: '../energy-sparks_analytics'

# Using master due to it having a patch which doesn't override Enumerable#sum if it's already defined
# Last proper release does that, causing all kinds of weird behaviour (+ not defined etc)
gem 'statsample', github: 'Energy-Sparks/statsample', branch: 'update-gems-and-awesome-print'

# Assets
gem 'bootstrap4-datetime-picker-rails' # For tempus dominus date picker
gem 'font-awesome-sass'
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'momentjs-rails'
gem 'sass-rails' # Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets

# Pagination
gem 'pagy'

# Geocoding
gem 'geocoder'
gem 'rgeo-geojson'

# APIs / remote services
gem 'aws-sdk-s3'
gem 'eventbrite_sdk' # Eventbrite for training page
gem 'faraday'
gem 'faraday-follow_redirects'
gem 'MailchimpMarketing'
gem 'mailgun_rails' # Email service
gem 'twilio-ruby' # For SMS notifications

# Assets for Emails
gem 'bootstrap-email'

# Frontend
gem 'bootstrap', '~> 4' # Use bootstrap for responsive layout
gem 'cocoon' # nested forms
gem 'simple_form'
gem 'view_component'

# JS Templating
gem 'handlebars_assets'
# Template variables
gem 'mustache', '~> 1.0'

# User input
gem 'trix-rails', require: 'trix'

# Auth & Users
gem 'cancancan', '~> 3' # Use cancancan for authorization
gem 'devise' # Use devise for authentication

# Utils
gem 'groupdate' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby] # for Windows

# Bundle update installs 0.7.0 for some weird reason!
gem 'dotenv-rails' # Shim to load environment variables from .env into ENV in development.
gem 'friendly_id'

# Sitemap
gem 'sitemap_generator'

# Reduce log noise in dev and test
gem 'lograge'

# Exception handling
gem 'oj'
gem 'rollbar'

# Internationalisation
gem 'i18n-tasks', '~> 1.0.10'
gem 'mobility', '~> 1.2.9'
gem 'mobility-actiontext', '~> 1.1.1'

# Background jobs
gem 'good_job'

# Spreadsheet parsing
# Switch to custom branch that incorporates some necessary bug fixes
gem 'roo', git: 'https://github.com/Energy-Sparks/roo.git', branch: 'bug-fix-branch'
gem 'roo-xls'

# Used to handle mail processing for the admin mailer
gem 'premailer-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet', require: false # use bullet to optimise queries
  gem 'byebug', platform: :mri
  gem 'climate_control'
  gem 'factory_bot_rails'
  gem 'fakefs', require: 'fakefs/safe'
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'knapsack'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rb-readline', require: false
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'terminal-notifier', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'webmock'
  gem 'wisper-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'erb_lint', require: false
  gem 'fasterer'
  gem 'listen' # listen for file changes - what's this used by?
  gem 'overcommit'
  gem 'pry' # last release 2013, still used?
  gem 'pry-byebug'
  gem 'scout_apm'
  gem 'web-console'
  #  gem 'rack-mini-profiler'
  #  gem 'memory_profiler'
  #  gem 'i18n-debug'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'show_me_the_cookies'
  gem 'simplecov', require: false, group: :test
  gem 'test-prof'
  gem 'timecop'
end
