namespace :after_party do
  desc 'Deployment task: add_peak_kw_alert'
  task add_peak_kw_alert: :environment do
    puts "Running deploy task 'add_peak_kw_alert'"

    AlertType.create(
      frequency: :termly,
      title: "Peak KW",
      description: "Analyses a school’s peak electricity kW usage on school days. A high usage is indicative either of inefficient appliances e.g. old-style fluorescent lighting or poor policies in turning off electrical appliances off during the day. May also pick up high kitchen usage in middle of day. Rating set to: 10 if < 0.015 kW/m2 (150W/m2), otherwise linearly between 0.015 (good = 10.0) and 0.02 (bad = 0.0), as per benchmark charts in the appendix.",
      class_name: 'AlertElectricityPeakKWVersusBenchmark',
      source: 'analytics'
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
