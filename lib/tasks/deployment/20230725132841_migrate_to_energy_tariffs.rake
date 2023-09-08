namespace :after_party do
  desc 'Deployment task: migrate_to_energy_tariffs'
  task migrate_to_energy_tariffs: :environment do
    puts "Running deploy task 'migrate_to_energy_tariffs'"

    # This service has since been removed
    # Database::EnergyTariffMigrationService.migrate_user_tariffs

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
