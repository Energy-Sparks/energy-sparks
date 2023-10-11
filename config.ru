require_relative 'config/environment'

# Used to configure a redirects from www.energysparks.uk and www-test.energysparks.uk to
# energysparks.uk and test.energysparks.uk.
#
# We exclude the Welsh subdomains (cy. and test-cy.)
if ENV['APPLICATION_HOST']
  use Rack::CanonicalHost, ENV['APPLICATION_HOST'], ignore: /.*cy\.energysparks\.uk/, cache_control: "max-age=#{1.hour.to_i}"
end

run Rails.application
