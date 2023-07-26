namespace :after_party do
  desc 'Deployment task: migrate_to_energy_tariffs'
  task migrate_to_energy_tariffs: :environment do
    puts "Running deploy task 'migrate_to_energy_tariffs'"

    ActiveRecord::Base.transaction do
      EnergyTariff.destroy_all

      UserTariff.all.order(:id).each do |ut|
        energy_tariff_prices = ut.user_tariff_prices.map do |utp|
          EnergyTariffPrice.new(
            start_time: utp.start_time,
            end_time: utp.end_time,
            units: utp.units,
            value: utp.value,
            description: utp.description
          )
        end

        energy_tariff_charges = ut.user_tariff_charges.map do |utc|
          EnergyTariffCharge.new(
            charge_type: utc.charge_type,
            units: utc.units,
            value: utc.value
          )
        end

        vat_rate = ut.vat_rate.nil? ? nil : ut.vat_rate.gsub(/\D/, '').to_i

        EnergyTariff.create!(
          ccl: ut.ccl,
          enabled: true,
          end_date: ut.end_date,
          meter_type: ut.fuel_type.to_sym,
          name: ut.name,
          source: :manually_entered,
          start_date: ut.start_date,
          tariff_holder_id: ut.school.id,
          tariff_holder_type: School,
          tariff_type: ut.flat_rate? ? :flat_rate : :differential,
          tnuos: ut.tnuos,
          vat_rate: vat_rate,
          meters: ut.meters,
          energy_tariff_charges: energy_tariff_charges,
          energy_tariff_prices: energy_tariff_prices
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
