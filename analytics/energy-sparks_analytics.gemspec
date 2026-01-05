# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'dashboard/version'

Gem::Specification.new do |s|
  s.name        = 'energy-sparks_analytics'
  s.version     = Dashboard::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = 'Energy sparks - analytics'
  s.homepage    = 'https://github.com/BathHacked/energy_sparks'
  s.description = 'Energy sparks - analytics - for charting'
  s.authors     = ['Philip Haile']
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- rspec/*`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.2'

  s.add_dependency 'activesupport'
  s.add_dependency 'benchmark-memory'
  s.add_dependency 'chroma'
  s.add_dependency 'hashdiff'
  s.add_dependency 'interpolate' # upstream repository archived since 2018
  s.add_dependency 'require_all'
  s.add_dependency 'roo'
  s.add_dependency 'roo-xls'
  s.add_dependency 'ruby-sun-times'
  # doesn't appear to be used - s.add_dependency 'soda-ruby', '~> 0' # version 1 released 2019
  s.add_dependency 'statsample' # no release since 2017 - using forked version in Gemfile
  s.add_dependency 'write_xlsx'

  s.metadata['rubygems_mfa_required'] = 'true'
end
