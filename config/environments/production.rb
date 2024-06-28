require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "energy_sparks_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

    # Local customisation below:
  # Allows mailer previews to be viewed on production
  # See also: config/initializers/action_mailer.rb
  config.action_mailer.show_previews = true
  # Rspec makes rails use spec/mailers/previews as the mail previews path
  config.action_mailer.preview_paths << Rails.root.join('spec', 'mailers', 'previews')
  # Attempt to read encrypted secrets from `config/secrets.yml.enc`.
  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true
  if ENV['RAILS_SERVE_STATIC_FILES'].present?
    # serve the assets from a different folder so they aren't served by NGINX
    config.public_file_server.enabled = true
    config.assets.prefix = "/static-assets"
    config.public_file_server.headers = { 'Access-Control-Allow-Origin' => "https://#{ENV['APPLICATION_HOST']}" }
  end
  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  config.action_controller.asset_host = ENV['ASSET_HOST'] if ENV['ASSET_HOST'].present?
  config.action_mailer.asset_host = ENV.fetch('ASSET_HOST'){ "https://#{ENV['APPLICATION_HOST']}" }
  config.active_storage.service = :amazon
  # session cookie has configurable name so that live and test logins are separated
  config.session_store :cookie_store, key: ENV.fetch('SESSION_COOKIE_NAME') { '_energy-sparks_session' }, domain: '.energysparks.uk'
  config.cache_store = :file_store, "#{root}/tmp/cache/rails_cache_store"
  # Default good job execution mode configuration for production
  # See https://github.com/bensheldon/good_job#configuration-options
  config.good_job.execution_mode = :external
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = { api_key: ENV['MG_API_KEY'], domain: ENV['MG_DOMAIN'] }
  config.mailchimp_client = MailchimpMarketing::Client.new({ api_key: ENV['MAILCHIMP_API_KEY'], server: ENV['MAILCHIMP_SERVER'] })
  config.ssl_options = { redirect: { exclude: -> request { request.path == '/up' } } }
end
