# frozen_string_literal: true

namespace :solar do
  desc 'Import MeterZ readings'
  task :import_meterz_readings, %i[start_date end_date] => :environment do |_t, args|
    start_date = args[:start_date]&.to_date
    end_date = args[:end_date]&.to_date
    MeterZInstallation.active.find_each do |installation|
      Solar::MeterZDownloadAndUpsert.new(installation: installation, start_date:, end_date:).perform
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: :import_meterz_readings)
  end
end
