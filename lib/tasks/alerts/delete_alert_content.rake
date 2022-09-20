namespace :alerts do
  desc 'Delete alert content'
  task delete_alert_content: [:environment] do
    puts "#{DateTime.now.utc} Delete content runs start"
    Alerts::ContentDeletionService.new.delete!
    puts "#{DateTime.now.utc} Delete content runs end"
  end
end
