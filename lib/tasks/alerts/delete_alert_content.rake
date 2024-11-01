namespace :alerts do
  desc 'Delete alert content'
  task delete_alert_content: [:environment] do
    puts "#{DateTime.now.utc} Delete alert content runs start"
    Alerts::ContentDeletionService.new.delete!
    Database::VacuumService.new([:alerts]).perform(vacuum: true)
    puts "#{DateTime.now.utc} Delete alert content runs end"
  end
end
