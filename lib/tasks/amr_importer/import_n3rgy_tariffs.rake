namespace :amr do
  desc "Import tariffs from N3RGY/DCC"
  task :import_n3rgy_tariffs, [:start_date, :end_date] => :environment do |_t, args|
    #Only expecting there to be one system-wide config
    #its just there to refer to import logs/messages
    # config = AmrDataFeedConfig.n3rgy_api.first

    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    puts "#{DateTime.now.utc} import_n3rgy_tariffs start"
    Meter.where(dcc_meter: true, consent_granted: true).last(1).each do |meter|
      Amr::N3rgyTariffsDownloadAndUpsert.new(meter: meter, start_date: start_date, end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} import_n3rgy_tariffs end"
  end
end



# def download_tariffs(mpxn, start_date, end_date, dtt = '')
#   meter = DCCMeters.meter(mpxn)
#
#   n3rgy_data = MeterReadingsFeeds::N3rgyData.new(api_key: meter.api_key, base_url: meter.base_url)
#
#   tariffs = n3rgy_data.tariffs(mpxn, meter.fuel_type, start_date, end_date)
#
#   save_yaml(meter.fuel_type, tariffs, mpxn, dtt)
# end
