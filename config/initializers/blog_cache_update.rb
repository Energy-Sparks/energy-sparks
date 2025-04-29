# Only run when web app is initialised (and not rake tasks etc)

if defined?(Rails::Server)
  Rails.application.config.after_initialize do
    UpdateBlogCacheJob.perform_later
  end
end
