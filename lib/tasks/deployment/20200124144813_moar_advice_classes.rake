namespace :after_party do
  desc 'Deployment task: moar_advice_classes'
  task moar_advice_classes: :environment do
    puts "Running deploy task 'moar_advice_classes'"

    # Put your task implementation HERE.
    AlertType.create!(
      frequency: :weekly,
      fuel_type: :gas,
      sub_category: :gas,
      title: "Gas costs advice",
      class_name: 'AdviceGasCosts',
      source: :analysis,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :electricity_use,
      title: "Electricity costs advice",
      class_name: 'AdviceElectricityCosts',
      source: :analysis,
      benchmark: false
    )

    AlertType.create!(
      frequency: :weekly,
      fuel_type: :electricity,
      sub_category: :baseload,
      title: "Baseload advice",
      class_name: 'AdviceBaseload',
      source: :analysis,
      benchmark: false
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
