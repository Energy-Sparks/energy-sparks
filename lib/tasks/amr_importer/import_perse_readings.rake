namespace :amr do
  desc "Import data from Perse"
  task import_perse_readings: :environment do |_t, args|
    puts "#{DateTime.now.utc} #{config.description} start"
    Meter.active.readings_api_perse_half_hourly.each do |meter|
      Amr::PerseUpsert.perform(meter, config)
    end
    puts "#{DateTime.now.utc} #{config.description} end"
  end
end
