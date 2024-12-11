# frozen_string_literal: true

namespace :amr do
  desc 'Import data from Perse'
  task import_perse_readings: :environment do |_t, _args|
    puts "#{DateTime.now.utc} import_perse_readings start"
    Meter.active.perse_api_half_hourly.each do |meter|
      Amr::PerseUpsert.perform(meter)
    end
    puts "#{DateTime.now.utc} import_perse_readings end"
  end
end
