namespace :amr do
  desc "Import tariffs from N3RGY/DCC"
  task :import_n3rgy_tariffs, [:start_date, :end_date] => :environment do |_t, args|
    start_date = Date.parse(args[:start_date]) if args[:start_date].present?
    end_date = Date.parse(args[:end_date]) if args[:end_date].present?

    meters = Meter.where(dcc_meter: true, consent_granted: true)

    puts "#{DateTime.now.utc} import_n3rgy_tariffs start for #{meters.count} meters"
    meters.each do |meter|
      if EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)
        Amr::N3rgyEnergyTariffLoader.new(meter: meter).perform
      else
        Amr::N3rgyTariffsDownloadAndUpsert.new(meter: meter).perform
      end
    end
    puts "#{DateTime.now.utc} import_n3rgy_tariffs end"
  end
end
