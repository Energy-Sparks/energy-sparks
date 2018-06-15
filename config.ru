# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.profile?
  use Rack::RubyProf, path: 'tmp/profile'
end

run Rails.application
