namespace :after_party do
  desc 'Deployment task: baseload_variation_alerts'
  task baseload_variation_alerts: :environment do
    puts "Running deploy task 'baseload_variation_alerts'"

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Variation in Seasonal Baseload",
      class_name: 'AlertSeasonalBaseloadVariation',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertSeasonalBaseloadVariation')

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Variation in Baseload between Days of the Week",
      class_name: 'AlertIntraweekBaseloadVariation',
      source: :analytics,
      has_ratings: true,
      benchmark: true
    ) unless AlertType.find_by_class_name('AlertIntraweekBaseloadVariation')


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
