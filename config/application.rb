require_relative 'boot'

require "rails"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnergySparks
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.eager_load_paths << Rails.root.join('lib/')
    # Pull in folders without namespacing
    config.eager_load_paths << Rails.root.join('app', 'models', 'areas')

    #config.time_zone = 'London'
    # optional - note it can be only :utc or :local (default is :utc)
    # HAS to be UTC for group by date to work
    config.active_record.default_timezone = :utc

    config.middleware.use Rack::Attack

    # To enable mailer previews
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
    config.eager_load_paths << Rails.root.join('lib', 'mailer_previews')
  end
end
