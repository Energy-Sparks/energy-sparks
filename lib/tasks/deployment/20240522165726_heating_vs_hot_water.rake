namespace :after_party do
  desc 'Deployment task: heating_vs_hot_water'
  task heating_vs_hot_water: :environment do
    puts "Running deploy task 'heating_vs_hot_water'"

    Comparison::Report.create!(
      key: :heating_vs_hot_water,
      reporting_period: :last_12_months,
      title: 'Heating vs hot water usage',
      public: false,
      report_group_id: 3
    ) unless Comparison::Report.find_by(key: :heating_vs_hot_water)


    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
