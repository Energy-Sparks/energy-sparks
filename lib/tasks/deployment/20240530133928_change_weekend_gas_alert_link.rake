namespace :after_party do
  desc 'Deployment task: change_weekend_gas_alert_link'
  task change_weekend_gas_alert_link: :environment do
    puts "Running deploy task 'change_weekend_gas_alert_link'"

    alert_type = AlertType.find_by_class_name('AlertWeekendGasConsumptionShortTerm')
    advice_page = AdvicePage.find_by_key(:gas_recent_changes)
    alert_type.update!(advice_page: advice_page, link_to_section: 'compare-last-week') if alert_type && advice_page

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
