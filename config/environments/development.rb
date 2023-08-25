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
  # Note: you may need to set this to false if there are asset pipeline issues when testing mailers
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
  config.action_mailer.asset_host = ENV['ASSET_HOST'] && ENV['APPLICATION_HOST'] ? ENV.fetch('ASSET_HOST'){ "http://#{ENV['APPLICATION_HOST']}" } : 'localhost:3000'

  config.mailchimp_client = MailchimpMarketing::Client.new({ api_key: ENV['MAILCHIMP_API_KEY'], server: ENV['MAILCHIMP_SERVER'] })

  # Uncomment to pull in locale files when testing with a local version of the Energy Sparks Analytics gem
  # config.i18n.load_path += Dir[Gem.loaded_specs['energy-sparks_analytics'].full_gem_path + '/config/locales/**/*.{rb,yml}']

  # Default good job execution mode configuration for development
  # See https://github.com/bensheldon/good_job#configuration-options
  config.active_job.queue_adapter = :good_job
  config.good_job.execution_mode = :async

  # This adds a 'mirror' locale that turns all translated text upside down so we can visually check for any
  # untranslated text in the erb templates.
  config.i18n.available_locales << :mirror
  I18n::Backend::Simple.include(I18n::Backend::Mirror)

  # Add these to your /etc/hosts file
  config.hosts << "energysparks.development"
  config.hosts << "cy.energysparks.development"
  config.hosts << "mirror.energysparks.development"

  # View components - Always place view in a sidecar directory when using the generator
  config.view_component.generate.sidecar = true
end

class MyAppFormatter < Logger::Formatter

    def call(severity, time, programName, message)

        "#{datetime}, #{severity}: #{message} from #{programName}\n"

    end

end
