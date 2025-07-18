namespace :after_party do
  desc 'Deployment task: remove_total_energy_use_page_from_alert_types'
  task remove_total_energy_use_page_from_alert_types: :environment do
    puts "Running deploy task 'remove_total_energy_use_page_from_alert_types'"

    total_energy_use = AdvicePage.find_by_key(:total_energy_use)
    AlertType.where(advice_page_id: total_energy_use.id).update_all(advice_page_id: nil) if total_energy_use

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
