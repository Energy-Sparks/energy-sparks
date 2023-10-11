namespace :after_party do
  desc 'Deployment task: alert_solar_generation'
  task alert_solar_generation: :environment do
    puts "Running deploy task 'alert_solar_generation'"

    unless AlertType.find_by(class_name: 'AlertSolarGeneration')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :electricity,
        sub_category: :electricity_use,
        title: 'Solar generation summary',
        class_name: 'AlertSolarGeneration',
        source: :analytics,
        has_ratings: false,
        benchmark: true
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
