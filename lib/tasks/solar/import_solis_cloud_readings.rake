# frozen_string_literal: true

namespace :solar do
  desc 'Import solis cloud readings'
  task :import_solis_cloud_readings, %i[start_date end_date] => :environment do |_t, args|
    start_date = args[:start_date]&.to_date
    end_date = args[:end_date]&.to_date
    SolisCloudInstallation.find_each do |installation|
      Solar::SolisCloudDownloadAndUpsert.new(installation: installation, start_date:, end_date:).perform
    end
  end
end
