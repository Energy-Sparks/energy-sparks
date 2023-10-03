Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Allows mailer previews to be viewed on production
  # See also: config/initializers/action_mailer.rb
  config.action_mailer.show_previews = true
  # Rspec makes rails use spec/mailers/previews as the mail previews path
  config.action_mailer.preview_path = Rails.root.join('spec', 'mailers', 'previews')

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true
  config.cache_store = :null_store

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'localhost' }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  config.mailchimp_client = MailchimpMarketing::MockClient.new

  # Default good job execution mode configuration for test
  # See https://github.com/bensheldon/good_job#configuration-options
  config.active_job.queue_adapter = :good_job
  config.good_job.execution_mode = :async

  # Uncomment to pull in locale files when testing with a local version of the Energy Sparks Analytics gem
  # config.i18n.load_path += Dir[Gem.loaded_specs['energy-sparks_analytics'].full_gem_path + '/config/locales/**/*.{rb,yml}']
end
