source 'https://rubygems.org'

ruby '2.5.1'

# Rails/Core
gem 'rails', '~> 5.2.0' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'puma' # Use Puma as the app server
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'bootsnap'

# Database/Data
gem 'pg' # Use postgresql as the database for Active Record
gem 'soda-ruby', :require => 'soda' # For the Socrata Open Data API

# Dashboard analytics
gem 'energy-sparks_analytics', '~> 0.8.3', git: 'https://github.com/PhilipTB/energy-sparks_analytics.git', branch: 'integration'

# Assets
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'jquery-ui-rails' # Use jquery UI for datepickers
gem 'sass-rails'# Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets
gem 'bootstrap4-datetime-picker-rails'
gem 'momentjs-rails'

# Frontend
gem 'bootstrap', '~> 4.1.0' # Use bootstrap for responsive layout
gem 'chartkick' # Use chartkick for usage graphs
gem 'redcarpet' # Use redcarpet to convert markdown
gem "font-awesome-rails" # Fonts
# Highcharts now included directly

# Spreadsheet export
gem 'rubyzip', '>= 1.2.1'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'

# For bulk record import in CSV etc
gem 'activerecord-import'

# JS Templating
gem 'handlebars_assets'

# User input
gem 'trix' # Use Trix editor for activity descriptions

# Auth & Users
gem 'devise' # Use devise for authentication
gem 'cancancan' # Use cancancan for authorization

# Utils
gem 'groupdate', '4.0.1' # Use groupdate to group usage stats
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'whenever', :require => false # Provides a syntax for writing and deploying cron jobs
gem 'dotenv-rails' # Shim to load environment variables from .env into ENV in development.
gem 'friendly_id' # Pretties up URLs
gem 'merit', git: 'https://github.com/jamesjefferies/merit.git', branch: 'rails-5.2-tweaks-specify-base-controller' # Reputation/achievements/rankings

# Exception handling
gem 'rollbar'
gem 'oj'

gem 'acts-as-taggable-on'

# Email service
gem 'mailgun_rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem "bullet" # use bullet to optimise queries
  gem 'rspec-rails', '~> 3.5'
  gem 'rails-controller-testing'
  gem "fakefs", require: "fakefs/safe"
  gem 'factory_bot_rails'
  gem 'climate_control'
  gem 'webmock'
  gem 'vcr'

  # Reduce log noise in dev and test
  gem 'lograge'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'better_errors'
  gem "binding_of_caller"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'annotate'
  gem 'pry'
  gem 'govuk-lint'#, '1.2.1' # Use govuk-lint to install Rubocop and Cops that correspond to the GDS Styleguide https://github.com/alphagov/govuk-lint
  gem 'overcommit'
  gem 'fasterer'
  gem 'bundler-audit'
end

group :test do
  gem 'test-prof'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem "chromedriver-helper"
  gem 'simplecov', :require => false, :group => :test
end

#Capistrano gems
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
end
