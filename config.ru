# frozen_string_literal: true
require_relative 'config/environment'

# Used to configure a redirects from www.energysparks.uk and www.test.energysparks.uk to
# energysparks.uk and test.energysparks.uk.
# This shouldn't apply to the Welsh subdomains (cy. and test-cy.) or ELB healthchecks (using app host IP)
if ENV['APPLICATION_HOST']
  use Rack::CanonicalHost, ENV['APPLICATION_HOST'], if: /^www\./, cache_control: "max-age=#{1.hour.to_i}"
end

run Rails.application
