namespace :after_party do
  desc 'Deployment task: create_admin_meter_statuses'
  task create_admin_meter_statuses: :environment do
    puts "Running deploy task 'create_admin_meter_statuses'"

    # Set updated at and created at so not to violate not-null constraint during create
    time_now = Time.now

    AdminMeterStatus.insert_all(
    [
      { label: 'Comms Issue - requires site visit', created_at: time_now, updated_at: time_now },
      { label: 'Comms Issue - site visit requested', created_at: time_now, updated_at: time_now },
      { label: 'AMR contract upgrade - required', created_at: time_now, updated_at: time_now },
      { label: 'AMR contract upgrade - requested', created_at: time_now, updated_at: time_now },
      { label: 'Meter upgrade - requested', created_at: time_now, updated_at: time_now },
      { label: 'No AMR', created_at: time_now, updated_at: time_now },
      { label: 'Minor Meter', created_at: time_now, updated_at: time_now },
      { label: 'On Data Feed', created_at: time_now, updated_at: time_now },
      { label: 'Manual Request', created_at: time_now, updated_at: time_now },
      { label: 'Requested', created_at: time_now, updated_at: time_now },
      { label: 'Meter issue raised', created_at: time_now, updated_at: time_now },
      { label: 'Disconnected meter', created_at: time_now, updated_at: time_now },
      { label: 'Meter issue - action required by school/MAT/Council ', created_at: time_now, updated_at: time_now },
      { label: 'Meter issue - action required by supplier/procurement/MOP', created_at: time_now, updated_at: time_now },
      { label: 'Data not available, created_at', created_at: time_now, updated_at: time_now }
    ])

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end