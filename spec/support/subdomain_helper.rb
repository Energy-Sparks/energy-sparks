module SubdomainHelper
  def within_subdomain(subdomain)
    before { host! "#{subdomain}.server.local" }
    after  { host! "www.server.local" }
    yield
  end
end

RSpec.configure do |config|
  config.include SubdomainHelper
end
