require_relative 'boot'

require "rails"
require "rails/all"
require "active_storage/engine"
require_relative "../lib/rack/x_robots_tag"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnergySparks
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.eager_load_paths << Rails.root.join('lib/')
    # Pull in folders without namespacing
    config.eager_load_paths << Rails.root.join('app', 'models', 'areas')

    #config.time_zone = 'London'
    # optional - note it can be only :utc or :local (default is :utc)
    # HAS to be UTC for group by date to work
    config.active_record.default_timezone = :utc

    config.middleware.use Rack::Attack
    config.middleware.use Rack::XRobotsTag

    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes.add 'id'
      ActionText::ContentHelper.allowed_attributes.add 'data-chart-config'
    end
  end
end
