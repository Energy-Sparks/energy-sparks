namespace :after_party do
  desc 'Deployment task: alert_electricity_usage_during_current_holiday'
  task alert_electricity_usage_during_current_holiday: :environment do
    puts "Running deploy task 'alert_electricity_usage_during_current_holiday'"

    unless AlertType.find_by(class_name: 'AlertElectricityUsageDuringCurrentHoliday')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :electricity,
        sub_category: :electricity_use,
        title: 'Alert Electricity Usage During Current Holiday',
        class_name: 'AlertElectricityUsageDuringCurrentHoliday',
        source: :analytics,
        has_ratings: true,
        benchmark: true
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
