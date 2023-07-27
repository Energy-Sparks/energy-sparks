module Database
  class EnergyTariffMigrationService
    def self.migrate_user_tariffs
      ActiveRecord::Base.transaction do
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
    end

    #Turns the Global Meter Attributes that are for accounting tariffs into
    #EnergyTariffs. We will be ignoring the economic tariffs as they aren't needed.
    def self.migrate_global_meter_attributes
      ActiveRecord::Base.transaction do
        GlobalMeterAttribute.where(attribute_type: 'accounting_tariff',
          replaced_by: nil, deleted_by: nil).each do |attribute|
            #either :electricity or :gas
            meter_type = meter_type(attribute)

            #global attributes only have standing charges
            energy_tariff_charges = [
              EnergyTariffCharge.new(
                charge_type: :standing_charge,
                units: :day,
                value: attribute.input_data['rates']['standing_charge']['rate'].to_f
              )
            ]
            #global attributes are flat rate only
            energy_tariff_prices = [
              EnergyTariffPrice.new(
                start_time: Time.zone.parse('00:00'),
                end_time: Time.zone.parse('23:30'),
                units: 'kwh',
                value: attribute.input_data['rates']['rate']['rate'].to_f
              )
            ]

            EnergyTariff.create!(
              ccl: false,
              enabled: true,
              end_date: Date.parse(attribute.input_data['end_date']),
              meter_type: meter_type,
              name: attribute.input_data['name'],
              source: :manually_entered,
              start_date: Date.parse(attribute.input_data['start_date']),
              tariff_holder: SiteSettings.current,
              tariff_type: :flat_rate,
              tnuos: false,
              vat_rate: nil,
              energy_tariff_charges: energy_tariff_charges,
              energy_tariff_prices: energy_tariff_prices
            )
        end
      end
    end

    def self.meter_type(attribute)
      return :electricity if attribute.meter_types.include?('electricity')
      return :gas if attribute.meter_types.include?('gas')
      return :solar_pv if attribute.meter_types.include?('solar_pv', 'solar_pv_consumed_sub_meter')
      return :exported_solar_pv if attribute.meter_types.include?('exported_solar_pv', 'solar_pv_exported_sub_meter')
      raise "Unexpected meter type"
    end
  end
end
