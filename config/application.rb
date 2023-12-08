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
      if EnergySparks::FeatureFlags.active?(:use_site_settings_current_prices)
        BenchmarkMetrics.set_current_prices(prices: SiteSettings.current_prices)
      end

      ActionText::ContentHelper.allowed_attributes.add 'id'
      ActionText::ContentHelper.allowed_attributes.add 'data-chart-config'
    end

    config.active_job.queue_adapter = :good_job
    config.good_job.retry_on_unhandled_error = false
    config.good_job.max_threads = 5
    config.good_job.enable_cron = false
    config.good_job.cleanup_preserved_jobs_before_seconds_ago = 30.days.to_i
    config.good_job.logger = Logger.new(File.join(Rails.root, 'log', 'good_job.log'))

    config.i18n.available_locales = [:en, :cy]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.view_component.show_previews = true
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    config.view_component.preview_route = "/admin/components/previews"
    config.view_component.preview_controller = "Admin::ComponentPreviewsController"
  end
end
