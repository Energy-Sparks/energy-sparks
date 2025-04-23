# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'roo', github: 'Energy-Sparks/roo', branch: 'bug-fix-branch'

# Forked statsample to do proper relases and to remove dependency on awesome_print which is no longer supported
# Last official release of statsample also had a problem where it overrode the definition of Array#sum with dodgy
# results - this is fixed in master, which is what this release is based upon.
gem 'statsample', github: 'Energy-Sparks/statsample', branch: 'ruby32'
# gem 'statsample', path: '../statsample'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw]

group :development, :test do
  # Useful for debugging
  gem 'pry-byebug'
end

group :development do
  gem 'aws-sdk-s3'
  gem 'fasterer'
  gem 'i18n-tasks'
  gem 'climate_control'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'rubocop-factory_bot'
  gem 'ruby-prof'
  gem 'overcommit'
end

# For tests
group :test do
  gem 'bundler-audit', platforms: :ruby
  gem 'factory_bot'
  gem 'rollbar'
  gem 'rspec'
  gem 'simplecov', require: false

  # Used by rspec html matcher
  gem 'compare-xml'
  gem 'nokogiri'
end
