# frozen_string_literal: true

# rubocop:disable-next Metrics/BlockLength
namespace :solar do
  desc 'Import solar edge data'
  task :import_solar_edge_readings, %i[start_date end_date reload] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : nil
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil
    reload = args[:reload].present? || false

    # only run this load on production, need to avoid exhausting credits
    # or refreshing access tokens across environments
    exit(1) unless ENV['ENVIRONMENT_IDENTIFIER'] == 'production'

    puts "#{DateTime.now.utc} import_solar_edge_readings start"

    SolarEdgeInstallation.for_active_schools.consented.find_each do |installation|
      puts "Running for #{installation.school.name} #{installation.site_id}"

      context = { installation: installation.id, start_date:, end_date:, reload:, job: :import_solar_edge_readings }

      if installation.active?
        begin
          Solar::SolarEdgeDownloadAndUpsert.new(installation: installation, start_date:, end_date:, reload:).perform
        rescue StandardError => e
          EnergySparks.log(e, context)
        end
      else
        begin
          installation.refresh_api_tokens!
        rescue StandardError => e
          EnergySparks.log(e, context)
        end
      end
    end

    puts "#{DateTime.now.utc} import_solar_edge_readings end"
  end
end
