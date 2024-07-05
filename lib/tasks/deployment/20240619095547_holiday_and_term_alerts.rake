namespace :after_party do
  desc 'Deployment task: holiday_and_term_alerts'
  task holiday_and_term_alerts: :environment do
    puts "Running deploy task 'holiday_and_term_alerts'"

    unless AlertType.find_by(class_name: 'AlertHolidayAndTermElectricityComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :electricity,
        sub_category: :electricity_use,
        title: 'Holiday and Term Electricity Comparison',
        class_name: 'AlertHolidayAndTermElectricityComparison',
        source: :analytics,
        has_ratings: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertHolidayAndTermGasComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :gas,
        sub_category: :heating,
        title: 'Holiday and Term Gas Comparison',
        class_name: 'AlertHolidayAndTermGasComparison',
        source: :analytics,
        has_ratings: true
      )
    end

    unless AlertType.find_by(class_name: 'AlertHolidayAndTermStorageHeaterComparison')
      AlertType.create!(
        frequency: :weekly,
        fuel_type: :storage_heater,
        sub_category: :storage_heaters,
        title: 'Holiday and Term Storage heater Comparison',
        class_name: 'AlertHolidayAndTermStorageHeaterComparison',
        source: :analytics,
        has_ratings: true
      )
    end

    Comparison::Report.create!(
      key: :holiday_and_term,
      title: 'Holiday and Term Comparison',
      public: false,
      report_group_id: 5
    ) unless Comparison::Report.find_by_id(:holiday_and_term)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
