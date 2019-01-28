class Rack::Attack
  Rack::Attack.blocklist('bad-robots') do |req|
    req.ip if /\S+\.php/.match?(req.path)
  end
end if Rail.env.production?
