namespace :blog do
  desc 'Update blog entries cache'
  task update_cache: [:environment] do
    puts "#{Time.zone.now} blog:update_cache start"
    BlogService.new.cache_feed!
    puts "#{Time.zone.now} blog:update_cache end"
  end
end
