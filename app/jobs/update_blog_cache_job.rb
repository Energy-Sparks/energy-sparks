class UpdateBlogCacheJob < ApplicationJob
  queue_as :default

  def perform
    BlogService.new.update_cache!
  end
end
