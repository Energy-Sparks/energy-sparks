module SubdomainHelper
  def within_subdomain(subdomain)
    before { host! "#{subdomain}.energysparks.test" }
    after  { host! "www.energysparks.test" }

    yield
  end
end

RSpec.configure do |config|
  config.include SubdomainHelper
end
