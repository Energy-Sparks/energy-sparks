namespace :after_party do
  desc 'Deployment task: solis_cloud_rework2025'
  task solis_cloud_rework2025: :environment do
    puts "Running deploy task 'solis_cloud_rework2025'"

    existing_schools = [['1300386381677086433', 628],
                        ['1300386381677086994', 625],
                        ['1300386381677702329', 991],
                        ['1300386381677086829', 587],
                        ['1300386381677086560', 627]].to_h

    Meter.find_by(mpan_mprn: 70_000_001_855_509).update!(school_id: 256)

    SolisCloudInstallation.find_each do |installation|
      meters = installation.meters.to_a
      installation.update_inverter_detail_list.each do |inverter|
        school = School.find_by(name: inverter['stationName']) || School.find(existing_schools[installation.api_id])
        installation.schools << school unless installation.schools.include?(school)
        meter = meters.find { |meter| meter.meter_serial_number == inverter['stationId'] }
        if meter
          meter.update!(name: installation.meter_name(inverter['sn']), meter_serial_number: inverter['sn'])
        elsif meters.pluck(:meter_serial_number).exclude?(inverter['sn'])
          installation.create_meter(inverter['sn'], school.id)
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
