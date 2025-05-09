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

  s.add_dependency 'activesupport', '>= 6.0', '< 8.1'
  s.add_dependency 'benchmark-memory', '~> 0'
  s.add_dependency 'chroma', '~> 0'
  s.add_dependency 'hashdiff', '~> 1'
  s.add_dependency 'interpolate', '~> 0.3.0' # upstream repository archived since 2018
  s.add_dependency 'require_all', '~> 3'
  s.add_dependency 'roo', '~> 2'
  s.add_dependency 'roo-xls', '~> 1'
  s.add_dependency 'ruby-sun-times', '~> 0'
  # doesn't appear to be used - s.add_dependency 'soda-ruby', '~> 0' # version 1 released 2019
  s.add_dependency 'statsample', '~> 2' # no release since 2017 - using forked version in Gemfile
  s.add_dependency 'write_xlsx', '~> 1'

  s.metadata['rubygems_mfa_required'] = 'true'
end
