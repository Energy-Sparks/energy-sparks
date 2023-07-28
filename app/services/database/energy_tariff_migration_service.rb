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

    def self.migrate_school_group_meter_attributes
      ActiveRecord::Base.transaction do
        SchoolGroup.all.order(:id).each do |school_group|
        #If a school group has any time-varying economic tariffs (there are 11 of these) then
        #we will use these to create new EnergyTariff records and their accounting tariffs
        #will be ignored.
        if has_time_varying_economic_tariffs?(school_group)
          migrate_school_group_economic_tariffs(school_group)
        else
          #If a group does not have time-varying economic tariffs, but has accounting tariffs
          #(e.g. Bath, Futura Learning) then we will create new EnergyTariff records from the
          #accounting tariffs as described below
          #
          #Need to translate both accounting_tariff and accounting_tariff_differential
          migrate_school_grouo_accounting_tariffs(school_group)
        end
        end
      end
    end

    #Does the group have any time varying tariffs?
    def self.has_time_varying_economic_tariffs?(school_group)
      school_group.meter_attributes.where(
        attribute_type: 'economic_tariff_change_over_time').active.any?
    end

    #Does the group have any accounting tariffs?
    def self.has_accounting_tariffs?(school_group)
      school_group.meter_attributes.where(
        attribute_type: %w[accounting_tariff accounting_tariff_differential]).active.any?
    end

    #Determine tariff type from accounting tariff / accounting tariff differential attribute
    def self.tariff_type(attribute)
      if attribute.input_data['rates']['daytime_rate'].present?
        :differential
      else
        :flat_rate
      end
    end

    #Economic tariffs don't have any charges, so we just need to migrate the prices
    #and ensure we're using the right type of tariff
    def self.migrate_school_group_economic_tariffs(school_group)
      school_group.meter_attributes.where(attribute_type: 'economic_tariff_change_over_time').active.each do |attribute|
          #If a time varying tariff has day/time time rates we can ignore the flat rate. The team
          #are currently required to add this for validation reasons.
          tariff_type = tariff_type(attribute)
          #There are some invalid/incorrect differential economic tariffs for Swansea (school group 11)
          #So in this case, just use the flat rate
          tariff_type = :flat_rate if school_group.slug == "swansea-abertawe"
          meter_type = meter_type(attribute)

          if tariff_type == :flat_rate
            energy_tariff_prices = [
              EnergyTariffPrice.new(
                start_time: Time.zone.parse('00:00'),
                end_time: Time.zone.parse('23:30'),
                units: 'kwh',
                value: attribute.input_data['rates']['rate']['rate'].to_f
              )
            ]
          else
            energy_tariff_prices = [
              EnergyTariffPrice.new(
                start_time: time_for_rate_type_period(attribute, 'daytime_rate', 'from'),
                end_time: time_for_rate_type_period(attribute, 'daytime_rate', 'to'),
                units: 'kwh',
                value: attribute.input_data['rates']['daytime_rate']['rate'].to_f
              ),
              EnergyTariffPrice.new(
                start_time: time_for_rate_type_period(attribute, 'nighttime_rate', 'from'),
                end_time: time_for_rate_type_period(attribute, 'nighttime_rate', 'to'),
                units: 'kwh',
                value: attribute.input_data['rates']['nighttime_rate']['rate'].to_f
              ),
            ]
          end

          EnergyTariff.create!(
            ccl: false,
            enabled: true,
            end_date: Date.parse(attribute.input_data['end_date']),
            meter_type: meter_type,
            name: attribute.input_data['name'],
            source: :manually_entered,
            start_date: Date.parse(attribute.input_data['start_date']),
            tariff_holder: school_group,
            tariff_type: tariff_type,
            tnuos: false,
            vat_rate: nil,
            energy_tariff_prices: energy_tariff_prices
          )
      end
    end

    #meter_types are gas, electricity, or aggregated. Aggregate always existing with fuel type
    def self.migrate_school_group_accounting_tariffs(school_group)
      return unless has_accounting_tariffs?(school_group)
    end

    def self.time_for_rate_type_period(attribute, rate_type = 'daytime_rate', range = 'from')
      return nil unless attribute.input_data['rates'][rate_type].present?
      return nil unless attribute.input_data['rates'][rate_type][range].present?

      period = attribute.input_data['rates'][rate_type][range]

      #meter attributes uses 24:00 as the final period of the day, for its
      #exclusive range. So spot this and return last half-hourly period
      return "23:30" if range == 'to' && period['hour'] == '24'

      #rubocop:disable Rails/Date
      #use the TimeOfDay class to convert to a time
      time_of_day = TimeOfDay.new(period['hour'].to_i, period['minutes'].to_i).to_time
      #rubocop:enable Rails/Date

      #roll back 30 minutes for the end of the tariff time range, as we're converting from
      #an exclusive range, to an inclusive range. Which means the end should be the
      #previous half-hourly period. Start ranges ("from") remain unchanged.
      if range == 'to'
        time_of_day = time_of_day.advance(minutes: -30)
      end
      time_of_day.to_s(:time)
    end
  end
end
