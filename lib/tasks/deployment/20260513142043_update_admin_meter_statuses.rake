# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_admin_meter_statuses'
  task update_admin_meter_statuses: :environment do
    puts "Running deploy task 'update_admin_meter_statuses'"

    # FROM
    # 1  => 'Comms issue - requires site visit'
    # 2  => 'Comms issue - site visit planned'
    # 17 => 'Comms issue - under investigation'
    # 16 => 'Meter issue - action required by Energy Sparks'
    # 13 => 'Meter issue - action required by school/MAT/Council'
    # 14 => 'Meter issue - action required by supplier/procurement/MOP'

    # TO
    # 11 => 'Meter issue raised'

    Meter.where(admin_meter_statuses_id: [1, 2, 17, 16, 13, 14])
         .update(admin_meter_statuses_id: 11)

    # FROM
    # 18 => 'Meter no longer required'

    # TO
    # 19 => 'Not required' (or 'Data not required' if working with older database)

    Meter.where(admin_meter_statuses_id: 18)
         .update(admin_meter_statuses_id: 19)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
