namespace :after_party do
  desc 'Deployment task: add_hot_water_insulation_and_heating_school_days_alerts'
  task add_hot_water_insulation_and_heating_school_days_alerts: :environment do
    puts "Running deploy task 'add_hot_water_insulation_and_heating_school_days_alerts'"

    # Put your task implementation HERE.
    AlertType.create(
      fuel_type: :gas,
      sub_category: :hot_water,
      frequency: :weekly,
      title: "Hot water insulation advice",
      description: "Hot water insulation advice",
      class_name: 'AlertHotWaterInsulationAdvice',
      show_ratings: true,
      has_variables: true,
      source: 'analytics'
    )

    AlertType.create(
      fuel_type: :gas,
      sub_category: :heating,
      frequency: :weekly,
      title: "Heating on on school days",
      description: "Counts the number of days the school has the heating on each year, compares with average and exemplar. Tries to persuade the school to turn its heating off earlier and on later in the year. Calculates the impact of reducing usage to that of average and exemplar (turning heating off during the warmest days it was on)",
      class_name: 'AlertHeatingOnSchoolDays',
      show_ratings: true,
      has_variables: true,
      source: 'analytics'
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190510152810'
  end
end
    # AlertType.create(
    #   fuel_type: :gas,
    #   sub_category: :heating,
    #   frequency: :weekly,
    #   title: "Heating on on non school days",
    #   description: "Heating on on non school days",
    #   class_name: 'AlertHeatingOnNonSchoolDays',
    #   show_ratings: true,
    #   has_variables: true,
    #   source: 'analytics'
    # )

    # AlertType.create(
    #   frequency: :termly,
    #   title: "Impending holiday",
    #   description: "Impending holiday",
    #   class_name: 'AlertImpendingHoliday',
    #   show_ratings: true,
    #   has_variables: true,
    #   source: 'analytics'
    # )
