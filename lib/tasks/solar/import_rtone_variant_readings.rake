namespace :solar do
  desc "Import rtone variant api readings"
  task :import_rtone_variant_readings, [:start_date, :end_date] => :environment do |_t, args|

    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : nil
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil

    puts "#{DateTime.now.utc} import_rtone_variant_readings start"
    RtoneVariantInstallation.all.each do |installation|
      puts "Running for #{installation.rtone_meter_id}"
      Solar::RtoneVariantDownloadAndUpsert.new(installation: installation, start_date: start_date, end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} import_rtone_variant_readings end"
  end
end
