# frozen_string_literal: true

namespace :data_feeds do
  desc 'Load calorific values from National Gas'
  task national_gas_calorific_values: :environment do
    api = DataFeeds::NationalGas.new
    LocalDistributionZone.find_each do |zone|
      next if ENV['ZONE'] && ENV['ZONE'] != zone.code

      latest_reading = zone.readings.by_date.last&.date
      from_date = latest_reading ? latest_reading + 1.day : 2.years.ago.to_date
      body = api.find_gas_data_download(from_date, Date.current, zone.publication_id)
      CSV.parse(body, headers: true, header_converters: :symbol).map(&:to_h).each do |row|
        begin
          LocalDistributionZoneReading.create!(local_distribution_zone: zone, calorific_value: row[:value].to_f,
                                               date: Date.parse(row[:applicable_for]))
        rescue StandardError => e
          EnergySparks::Log.exception(e, job: :national_gas_calorific_values, row:, zone:)
        end
      end
    end
  end
end
