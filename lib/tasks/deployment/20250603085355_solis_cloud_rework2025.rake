namespace :after_party do
  desc 'Deployment task: solis_cloud_rework2025'
  task solis_cloud_rework2025: :environment do
    puts "Running deploy task 'solis_cloud_rework2025'"

    existing_schools = [['1300386381677086433', 628],
                        ['1300386381677086994', 625],
                        ['1300386381677702329', 991],
                        ['1300386381677086829', 587],
                        ['1300386381677086560', 627]].to_h

    AmrDataFeedReading.where(amr_data_feed_config: AmrDataFeedConfig.find_by!(identifier: 'solis-cloud')).delete_all

    SolisCloudInstallation.find_each do |installation|
      installation.meters.find_each { |meter| MeterManagement.new(meter).delete_meter! }
      installation.update_inverter_detail_list.each do |inverter|
        school = School.find_by(name: inverter['stationName']) || School.find(existing_schools[installation.api_id])
        installation.schools << school unless installation.schools.include?(school)
        installation.create_meter(inverter['sn'], school.id)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
