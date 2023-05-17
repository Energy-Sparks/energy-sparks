namespace :meters do
  desc 'Export tariff price and standing charge data to a csv file'
  task :tariff_price_and_standing_charge_exporter => :environment do |_t, args|
    CSV.open("tmp/tariff_import_log.csv", "wb") do |csv|
      csv << TariffImportLog.attribute_names
      TariffImportLog.where(source: 'n3rgy-api').each do |tariff_import_log|
        csv << tariff_import_log.attributes.values
      end
    end

    CSV.open("tmp/tariff_price.csv", "wb") do |csv|
      csv << TariffPrice.attribute_names
      TariffPrice.find_each do |tariff_price|
        csv << tariff_price.attributes.values
      end
    end

    CSV.open("tmp/tariff_standing_charge.csv", "wb") do |csv|
      csv << TariffStandingCharge.attribute_names
      TariffStandingCharge.find_each do |tariff_standing_charge|
        csv << tariff_standing_charge.attributes.values
      end
    end
  end
end
