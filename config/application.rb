require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnergySparks
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Local customisations
    config.active_support.cache_format_version = 7.1
    config.autoload_lib(ignore: %w(generators))
    # For our application date helpers to use to optionally display times in configured zone
    config.display_timezone = 'London'
    config.middleware.use Rack::Attack
    require_relative '../lib/rack/x_robots_tag'
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
      ActionText::ContentHelper.allowed_attributes.add 'allow'
      ActionText::ContentHelper.allowed_attributes.add 'allowfullscreen'
      ActionText::ContentHelper.allowed_tags = Class.new.include(ActionText::ContentHelper).new.sanitizer_allowed_tags
      ActionText::ContentHelper.allowed_tags.add 'iframe'
    end
    config.exceptions_app = self.routes
    # Default good job execution mode configuration for test
    # See https://github.com/bensheldon/good_job#configuration-options
    config.good_job.max_threads = 5
    config.good_job.cleanup_preserved_jobs_before_seconds_ago = 30.days.to_i # default 14 days
    config.i18n.available_locales = [:en, :cy]
    config.i18n.default_locale = :en
    config.i18n.enforce_available_locales = true
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.view_component.show_previews = true
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    config.view_component.preview_route = "/admin/components/previews"
    config.view_component.default_preview_layout = "component_preview"
    config.view_component.preview_controller = "Admin::ComponentPreviewsController"
    config.active_record.encryption.primary_key = '0UmFz7KnehkidvKKhMWrnvStuFFzM0oK'
    config.active_record.encryption.deterministic_key = 'eo84dBizRt6e4I68aD8IUrCBjuzTt7c7'
    config.active_record.encryption.key_derivation_salt = 'IXTWKMlViWaALgj3k2UNhIouWdOyXAwm'
    config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA256
    config.active_storage.variant_processor = :mini_magick # keep old default for now, breaks validation
  end
end
