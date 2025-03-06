namespace :amr do
  desc "Import data from N3RGY/DCC"
  task :import_n3rgy_readings, [:start_date, :end_date] => :environment do |_t, args|
    config = AmrDataFeedConfig.n3rgy_api.first

    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    puts "#{DateTime.now.utc} #{config.description} start"
    Meter.active.consented.each do |meter|
      Amr::N3rgyReadingsDownloadAndUpsert.new(
        meter: meter,
        config: config,
        override_start_date: start_date,
        override_end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} #{config.description} end"
  end

  task reload_n3rgy_readings: :environment do
    config = AmrDataFeedConfig.n3rgy_api.first

    puts "#{DateTime.now.utc} #{config.description} reload start"
    Meter.active.consented.each do |meter|
      Amr::N3rgyReadingsDownloadAndUpsert.new(meter: meter, config: config, reload: true).perform
    end
    puts "#{DateTime.now.utc} #{config.description} reload end"
  end
end
