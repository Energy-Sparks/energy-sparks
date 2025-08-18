# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.2.2'

gem 'rails', '~> 7.2.2'

# Rails/Core
gem 'bootsnap'
gem 'image_processing', '~> 1.14'
gem 'jbuilder', '~> 2.14' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'puma' # Use Puma as the app server
gem 'rack'
gem 'rack-attack'
gem 'rack-canonical-host' # Redirect www to root
gem 'rexml' # ruby 3 related - seems like should be a dependency of bootsnap
gem 'ruby-limiter'
gem 'sprockets'
gem 'stateful_enum' # extends ActiveRecord::Enum with state
gem 'wisper' # publish subscribe for ruby objects

# Database/Data
gem 'after_party' # load data after deploy
gem 'auto_strip_attributes', '~> 2.5'
gem 'closed_struct'
gem 'mechanize' # For GIAS data downloader
gem 'pg'
gem 'scenic'

# Dashboard analytics
gem 'energy-sparks_analytics', path: 'analytics'

# Using master due to it having a patch which doesn't override Enumerable#sum if it's already defined
# Last proper release does that, causing all kinds of weird behaviour (+ not defined etc)
gem 'statsample', github: 'Energy-Sparks/statsample', branch: 'ruby32'

# Assets
gem 'active_storage_validations'
gem 'bootstrap4-datetime-picker-rails' # For tempus dominus date picker
gem 'font-awesome-sass'
gem 'importmap-rails'
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'momentjs-rails'
gem 'sassc', github: 'tbhi/sassc-ruby', branch: 'load_error'
gem 'sass-rails' # Use SCSS for stylesheets
gem 'terser'

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
gem 'faraday-retry'
gem 'MailchimpMarketing'
gem 'mailgun_rails' # Email service
gem 'twilio-ruby' # For SMS notifications

# Assets for Emails
gem 'bootstrap-email'

# Frontend
gem 'bootstrap', '~> 4' # Use bootstrap for responsive layout
gem 'cocoon' # nested forms
gem 'simple_form'
gem 'sortablejs-rails'
gem 'view_component'

# JS Templating
gem 'handlebars_assets'
# Template variables
gem 'mustache', '~> 1.0'

# Auth & Users
gem 'cancancan', '~> 3' # Use cancancan for authorization
gem 'devise' # Use devise for authentication

# Utils
gem 'groupdate' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: %i[windows jruby] # for Windows

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
gem 'i18n-tasks', '~> 1.0.15'
gem 'mobility', '~> 1.3.2'
gem 'mobility-actiontext', '~> 1.1.1'

# Background jobs
gem 'good_job'

# Spreadsheet parsing
# Switch to custom branch that incorporates some necessary bug fixes
gem 'roo', git: 'https://github.com/Energy-Sparks/roo.git', branch: 'bug-fix-branch'
gem 'roo-xls'

# Used to handle mail processing for the admin mailer
gem 'premailer-rails'

# Feature flags
gem 'flipper-active_record', '~> 1.3'
gem 'flipper-ui', '~> 1.3'

gem 'net-sftp'
gem 'rss'

group :development, :test do
  gem 'better_html'
  gem 'bullet', require: false # use bullet to optimise queries
  gem 'climate_control'
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'knapsack'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'ruby-prof' # used by analytics
  gem 'terminal-notifier', require: false
  gem 'terminal-notifier-guard', require: false
  gem 'webmock'
  gem 'wisper-rspec', require: false
end

group :development, :production do
  gem 'lookbook'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'erb_lint', require: false
  gem 'fasterer'
  gem 'listen' # listen for file changes - what's this used by?
  gem 'overcommit'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec_rails'
  gem 'scout_apm'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'compare-xml' # used by rspec html matcher in analytics
  gem 'reverse_markdown'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'show_me_the_cookies'
  gem 'simplecov', require: false, group: :test
  gem 'sqlite3'
  gem 'test-prof'
end
