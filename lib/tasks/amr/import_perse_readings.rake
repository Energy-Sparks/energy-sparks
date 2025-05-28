# frozen_string_literal: true

namespace :amr do
  desc 'Import data from Perse'
  task import_perse_readings: :environment do |_t, _args|
    upserter = Amr::PerseUpsert.new
    Meter.active.perse_api_half_hourly.each { |meter| upserter.perform(meter) }
  end
end
