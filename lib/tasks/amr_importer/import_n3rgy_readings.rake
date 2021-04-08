namespace :amr do
  desc "Import data from N3RGY/DCC"
  task :import_n3rgy_readings, [:start_date, :end_date] => :environment do |_t, args|
    #Only expecting there to be one system-wide config
    #its just there to refer to import logs/messages
    config = AmrDataFeedConfig.n3rgy_api.first

    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    puts "#{DateTime.now.utc} #{config.description} start"
    Meter.where(dcc_meter: true, consent_granted: true).last(1).each do |meter|
      Amr::N3rgyDownloadAndUpsert.new(meter: meter, config: config, start_date: start_date, end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} #{config.description} end"
  end
end
