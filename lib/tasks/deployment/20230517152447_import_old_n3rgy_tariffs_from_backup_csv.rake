namespace :after_party do
  desc 'Deployment task: import_old_n3rgy_tariffs_from_backup_csv'
  task import_old_n3rgy_tariffs_from_backup_csv: :environment do
    puts "Running deploy task 'import_old_n3rgy_tariffs_from_backup_csv'"

    # tariff_import_log = YAML.load(File.read(File.expand_path('../tmp/tariff_import_log.yml', __FILE__)))
    # TariffImportLog.upsert_all(tariff_import_log)

    # tariff_price = YAML.load(File.read(File.expand_path('../tmp/tariff_price.yml', __FILE__)))
    # TariffPrice.upsert_all(tariff_price)

    # tariff_standing_charge = YAML.load(File.read(File.expand_path('../tmp/tariff_standing_charge.yml', __FILE__)))
    # TariffStandingCharge.upsert_all(tariff_standing_charge)

    keys = TariffImportLog.attribute_names
    CSV.open("tmp/tariff_import_log.csv", "rb").drop(1).each do |values|
      TariffImportLog.create!(Hash[keys.zip(values)])
    end

    keys = TariffPrice.attribute_names
    CSV.open("tmp/tariff_price.csv", "rb").drop(1).each do |values|
      TariffPrice.create!(Hash[keys.zip(values)])
    end

    keys = TariffStandingCharge.attribute_names
    CSV.open("tmp/tariff_standing_charge.csv", "rb").drop(1).each do |values|
      TariffStandingCharge.create!(Hash[keys.zip(values)])
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end