if defined?(Rails::Server)
  Rails.application.config.after_initialize do
    UpdateBlogCacheJob.perform_later
  end
end
