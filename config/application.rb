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

    # For our application date helpers to use to optionally display times in configured zone
    config.display_timezone = 'London'

    config.middleware.use Rack::Attack
    config.middleware.use Rack::XRobotsTag

    # uploaded SVG files are served as octet stream by default for security
    # this will remove them from the list of binary file types, but is a slight risk
    config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")

    # session cookie config will be overridden in production.rb
    config.session_store :cookie_store, key: '_energy-sparks_session'

    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes.add 'id'
      ActionText::ContentHelper.allowed_attributes.add 'data-chart-config'
    end

    config.i18n.available_locales = [:en, :cy]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
  end
end
