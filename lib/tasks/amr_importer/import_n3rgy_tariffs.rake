namespace :amr do
  desc "Import tariffs from N3RGY/DCC"
  task :import_n3rgy_tariffs, [:start_date, :end_date] => :environment do |_t, args|
    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    meters = Meter.active.consented

    puts "#{DateTime.now.utc} import_n3rgy_tariffs start for #{meters.count} meters"
    meters.each do |meter|
      Amr::N3rgyEnergyTariffLoader.new(meter: meter).perform
    end
    puts "#{DateTime.now.utc} import_n3rgy_tariffs end"
  end
end
