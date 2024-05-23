namespace :after_party do
  desc 'Deployment task: create_annual_energy_use_report'
  task create_annual_energy_use_report: :environment do
    puts "Running deploy task 'create_annual_energy_use_report'"

    Comparison::Report.create!(
      key: :annual_energy_use,
      reporting_period: :last_12_months,
      title: "Annual Energy Use",
      report_group_id: 1,
      public: false
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
