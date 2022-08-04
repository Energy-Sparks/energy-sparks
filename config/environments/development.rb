Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store, { size: 256.megabytes }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  # To use amazon locally, set ACTIVE_STORAGE_SERVICE = amazon in your .env file
  # and ensure you have the AWS credentials set up in your .env file
  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE'){ :local }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.action_controller.enable_fragment_cache_logging = true

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # config.active_record.logger = nil

  # For when you need severity etc in log file
  # logger           = ActiveSupport::Logger.new(STDOUT)
  # logger.formatter = proc do | severity, time, progname, msg |
  #   "#{severity}: #{msg}\n"
  # end

  # config.logger = ActiveSupport::TaggedLogging.new(logger)

  config.log_level = :debug

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Use mailcatcher locally - https://github.com/sj26/mailcatcher
  # NOTE not using default port!
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: '127.0.0.1', port:ENV.fetch('LOCAL_SMTP_PORT') { 1025 } }
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.asset_host = ENV.fetch('ASSET_HOST'){ "http://#{ENV['APPLICATION_HOST']}" }

  config.mailchimp_client = MailchimpMarketing::Client.new({ api_key: ENV['MAILCHIMP_API_KEY'], server: ENV['MAILCHIMP_SERVER'] })

  # Add these to your /etc/hosts file
  config.hosts << "energysparks.development"
  config.hosts << "cy.energysparks.development"
end

class MyAppFormatter < Logger::Formatter

    def call(severity, time, programName, message)

        "#{datetime}, #{severity}: #{message} from #{programName}\n"

    end

end
