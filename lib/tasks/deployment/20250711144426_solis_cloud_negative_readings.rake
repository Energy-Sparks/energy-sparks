namespace :after_party do
  desc 'Deployment task: solis_cloud_negative_readings'
  task solis_cloud_negative_readings: :environment do
    puts "Running deploy task 'solis_cloud_negative_readings'"

    Meter.where.not(solis_cloud_installation_id: nil).find_each do |meter|
      meter.amr_data_feed_readings.delete_all
      meter.amr_validated_readings.delete_all
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
