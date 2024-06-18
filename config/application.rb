require_relative "boot"

require "rails/all"
require_relative "../lib/rack/x_robots_tag"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnergySparks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Local customisations
    config.autoload_lib(ignore: %w(assets tasks generators))
    # Pull in folders without namespacing
    config.eager_load_paths << Rails.root.join('app/models/areas')
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
      # https://stackoverflow.com/questions/77366033/allow-actiontext-tags-in-rails-7-1-with-new-sanitizers
      ActionText::ContentHelper.allowed_attributes =
        Class.new.include(ActionText::ContentHelper).new.sanitizer_allowed_attributes
      ActionText::ContentHelper.allowed_attributes.add 'id'
      ActionText::ContentHelper.allowed_attributes.add 'data-chart-config'
    end
    # Default good job execution mode configuration for test
    # See https://github.com/bensheldon/good_job#configuration-options
    config.active_job.queue_adapter = :good_job
    config.good_job.execution_mode = :async
    config.good_job.retry_on_unhandled_error = false
    config.good_job.max_threads = 5
    config.good_job.enable_cron = false
    config.good_job.cleanup_preserved_jobs_before_seconds_ago = 30.days.to_i
    config.good_job.logger = Logger.new(File.join(Rails.root, 'log', 'good_job.log'))
    config.good_job.smaller_number_is_higher_priority = true
    config.i18n.available_locales = [:en, :cy]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.view_component.show_previews = true
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    config.view_component.preview_route = "/admin/components/previews"
    config.view_component.preview_controller = "Admin::ComponentPreviewsController"
    config.active_record.encryption.primary_key = '0UmFz7KnehkidvKKhMWrnvStuFFzM0oK'
    config.active_record.encryption.deterministic_key = 'eo84dBizRt6e4I68aD8IUrCBjuzTt7c7'
    config.active_record.encryption.key_derivation_salt = 'IXTWKMlViWaALgj3k2UNhIouWdOyXAwm'
  end
end
