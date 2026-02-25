namespace :after_party do
  desc 'Deployment task: ignore_in_inactive_meter_report'
  task ignore_in_inactive_meter_report: :environment do
    puts "Running deploy task 'ignore_in_inactive_meter_report'"

    AdminMeterStatus.where(label:
      ['Disconnected meter', 'Data not required', 'Data not available']
    ).update_all(ignore_in_inactive_meter_report: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
