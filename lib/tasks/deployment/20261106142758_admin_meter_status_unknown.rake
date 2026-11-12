# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: admin_meter_status_unknown'
  task admin_meter_status_unknown: :environment do
    puts "Running deploy task 'admin_meter_status_unknown'"

    admin_meter_status = AdminMeterStatus.find_by(label: 'Unknown')
    if admin_meter_status
      # rubocop:disable-next Rails/SkipsModelValidations
      Meter.where(admin_meter_statuses_id: nil).update_all(admin_meter_statuses_id: admin_meter_status.id)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
