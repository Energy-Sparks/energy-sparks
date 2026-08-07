# frozen_string_literal: true

namespace :amr do
  desc 'Import tariffs from N3RGY/DCC'
  task import_n3rgy_tariffs: :environment do
    meters = Meter.active.consented
    puts "#{DateTime.now.utc} import_n3rgy_tariffs start for #{meters.count} meters"
    meters.each { |meter| Amr::N3rgyEnergyTariffLoader.new(meter: meter).perform }
    puts "#{DateTime.now.utc} import_n3rgy_tariffs end"
  end
end
