namespace :solar do
  desc "Import rtone variant api readings"
  task :import_rtone_variant_readings, [:start_date, :end_date] => :environment do |_t, args|

    default_start_date = Date.yesterday - 5
    requested_start_date =  Date.parse(args[:start_date]) if args[:start_date].present?

    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    RtoneVariantInstallation.all.each do |installation|
      puts "Running for #{installation.rtone_meter_id}"

      start_date = if requested_start_date
                     requested_start_date
                   else
                     installation.latest_electricity_reading < default_start_date ? installation.latest_electricity_reading : default_start_date
                   end

      Solar::RtoneVariantDownloadAndUpsert.new(rtone_variant_installation: installation, start_date: start_date, end_date: end_date).perform
    end
  end
end
