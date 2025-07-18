namespace :alerts do
  desc 'Delete alert content'
  task delete_alert_content: [:environment] do
    puts "#{DateTime.now.utc} Delete alert content runs start"
    Alerts::ContentDeletionService.new.delete!
    Database::VacuumService.new([:alerts, :alert_errors, :dashboard_alerts, :find_out_mores, :management_priorities, :management_dashboard_tables, ]).perform(vacuum: true)
    puts "#{DateTime.now.utc} Delete alert content runs end"
  end
end
