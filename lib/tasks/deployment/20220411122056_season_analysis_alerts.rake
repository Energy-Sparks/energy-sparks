namespace :after_party do
  desc 'Deployment task: Configure new seasonal analysis alerts'
  task season_analysis_alerts: :environment do
    puts "Running deploy task 'season_analysis_alerts'"

    #Remove old alerts
    ["AlertHeatingOnOff",
     "AlertHeatingOnSchoolDays",
     "AlertHeatingOnNonSchoolDays",
     "AlertHeatingOnSchoolDaysStorageHeaters"
    ].each do |class_name|
      alert = AlertType.find_by_class_name(class_name)
      alert.destroy if alert.present?
    end

    #Configure the new ones
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Warn school when it's warm enough to turn their boilers off",
      class_name: 'AlertHeatingOff',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertHeatingOff')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :heating,
      title: "Warn school when it's warm enough to turn their storage radiators off",
      class_name: 'AlertTurnHeatingOffStorageHeater',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertTurnHeatingOffStorageHeater')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Gas heating usage in warm weather",
      class_name: 'AlertSeasonalHeatingSchoolDays',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeasonalHeatingSchoolDays')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :heating,
      title: "Storage heater usage in warm weather",
      class_name: 'AlertSeasonalHeatingSchoolDaysStorageHeaters',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeasonalHeatingSchoolDaysStorageHeaters')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
