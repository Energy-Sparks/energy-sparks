namespace :after_party do
  desc 'Deployment task: add_even_more_advice_classes'
  task add_even_more_advice_classes: :environment do
    puts "Running deploy task 'add_even_more_advice_classes'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :heating,
      title: "Gas meter breakdown advice",
      class_name: 'AdviceGasMeterBreakdownBase',
      source: :analysis,
      has_ratings: false,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Electricity meter breakdown advice",
      class_name: 'AdviceElectricityMeterBreakdownBase',
      source: :analysis,
      has_ratings: false,
      benchmark: false
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end