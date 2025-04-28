namespace :blog do
  desc 'Update blog entries cache'
  task update_cache: [:environment] do
    if Flipper.enabled?(:new_home_page)
      puts "#{Time.zone.now} blog:update_cache start"
      BlogService.new.update_cache!
      puts "#{Time.zone.now} blog:update_cache end"
    end
  end
end
