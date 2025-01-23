# frozen_string_literal: true

namespace :solar do
  desc 'Import solis cloud edge data'
  task :import_solis_cloud_readings, %i[start_date end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : nil
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil

    puts "#{DateTime.now.utc} import_solis_cloud_readings start"
    begin
      SolisCloudInstallation.find_each do |installation|
        puts "Running for #{installation.school.name} #{installation.site_id}"
        Solar::SolisCloudDownloadAndUpsert.new(installation: installation, start_date: start_date,
                                               end_date: end_date).perform
      end
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: :import_solis_cloud_reads)
    end
    puts "#{DateTime.now.utc} import_solar_edge_readings end"
  end
end
