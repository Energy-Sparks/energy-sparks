namespace :amr do
  desc "Import tariffs from N3RGY/DCC"
  task :import_n3rgy_tariffs, [:start_date, :end_date] => :environment do |_t, args|
    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    puts "#{DateTime.now.utc} import_n3rgy_tariffs start"
    Meter.where(dcc_meter: true, consent_granted: true).each do |meter|
      Amr::N3rgyTariffsDownloadAndUpsert.new(meter: meter, start_date: start_date, end_date: end_date).perform
    end
    puts "#{DateTime.now.utc} import_n3rgy_tariffs end"
  end
end
