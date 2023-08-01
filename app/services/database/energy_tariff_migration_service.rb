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

    #Doesn't include user tariffs as that is being migrated via an
    #after party task
    def self.migrate_all
      migrate_all_meter_attributes
      migrate_tariff_prices
    end

    def self.migrate_all_meter_attributes
      migrate_global_meter_attributes
      migrate_global_solar_meter_attributes
      migrate_school_group_meter_attributes
      migrate_school_economic_tariffs
      migrate_meter_accounting_tariffs
    end

    #Turns the Global Meter Attributes that are accounting tariffs into
    #EnergyTariffs.
    def self.migrate_global_meter_attributes
      ActiveRecord::Base.transaction do
        GlobalMeterAttribute.where(attribute_type: 'accounting_tariff').active.each do |attribute|
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

    #Turns the Global Meter Attributes that are economic tariffs for solar pv
    #and solar export into Energy Tariffs
    def self.migrate_global_solar_meter_attributes
      solar_types = [:solar_pv, :exported_solar_pv]
      ActiveRecord::Base.transaction do
        GlobalMeterAttribute.where(attribute_type: 'economic_tariff').active.each do |attribute|
            meter_type = meter_type(attribute)
            #ignore economic tariffs for gas and electricity
            next unless solar_types.include?(meter_type)

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
              end_date: date_or_nil(attribute.input_data['end_date']),
              meter_type: meter_type,
              name: attribute.input_data['name'],
              source: :manually_entered,
              start_date: date_or_nil(attribute.input_data['start_date']),
              tariff_holder: SiteSettings.current,
              tariff_type: :flat_rate,
              tnuos: false,
              vat_rate: nil,
              energy_tariff_prices: energy_tariff_prices
            )
        end
      end
    end

    def self.migrate_school_group_meter_attributes
      ActiveRecord::Base.transaction do
        SchoolGroup.all.order(:id).each do |school_group|
          #If a school group has any time-varying economic tariffs (there are 11 of these) then
          #we will use these to create new EnergyTariff records and their accounting tariffs
          #will be ignored. This is because the team is creating economic tariffs and not
          #accounting tariffs, so these records provide better initial defaults
          if has_time_varying_economic_tariffs?(school_group)
            migrate_school_group_economic_tariffs(school_group)
          else
            #If a group does not have time-varying economic tariffs, but has accounting tariffs
            #(e.g. Bath, Futura Learning) then we will create new EnergyTariff records from
            #those tariffs
            #
            #Need to translate both accounting_tariff and accounting_tariff_differential
            migrate_school_group_accounting_tariffs(school_group)
          end
        end
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

          EnergyTariff.create!(
            ccl: false,
            enabled: true,
            end_date: date_or_nil(attribute.input_data['end_date']),
            meter_type: meter_type,
            name: attribute.input_data['name'],
            source: :manually_entered,
            start_date: date_or_nil(attribute.input_data['start_date']),
            tariff_holder: school_group,
            tariff_type: tariff_type,
            tnuos: false,
            vat_rate: nil,
            energy_tariff_prices: energy_tariff_prices(attribute.input_data['rates'], tariff_type)
          )
      end
    end

    #meter_types are gas, electricity, or aggregated. Aggregate always existing with fuel type
    def self.migrate_school_group_accounting_tariffs(school_group)
      return unless has_accounting_tariffs?(school_group)
      school_group.meter_attributes.where(
        attribute_type: %w[accounting_tariff accounting_tariff_differential]).active.each do |attribute|
          #account tariffs don't have day/night rates, so this returns the right results
          #regardless of attribute_type
          tariff_type = tariff_type(attribute)
          meter_type = meter_type(attribute)

          EnergyTariff.create!(
            ccl: false,
            enabled: true,
            end_date: date_or_nil(attribute.input_data['end_date']),
            meter_type: meter_type,
            name: attribute.input_data['name'],
            source: :manually_entered,
            start_date: date_or_nil(attribute.input_data['start_date']),
            tariff_holder: school_group,
            tariff_type: tariff_type,
            tnuos: false,
            vat_rate: nil,
            energy_tariff_prices: energy_tariff_prices(attribute.input_data['rates'], tariff_type),
            energy_tariff_charges: energy_tariff_charges(attribute.input_data['rates'])
          )
      end
    end

    def self.migrate_school_economic_tariffs
      ActiveRecord::Base.transaction do
        SchoolMeterAttribute.where(attribute_type: 'economic_tariff_change_over_time').active.each do |attribute|
          #If a time varying tariff has day/time time rates we can ignore the flat rate. The team
          #are currently required to add this for validation reasons.
          tariff_type = tariff_type(attribute)
          meter_type = meter_type(attribute)

          EnergyTariff.create!(
            ccl: false,
            enabled: true,
            end_date: date_or_nil(attribute.input_data['end_date']),
            meter_type: meter_type,
            name: attribute.input_data['name'],
            source: :manually_entered,
            start_date: date_or_nil(attribute.input_data['start_date']),
            tariff_holder: attribute.school,
            tariff_type: tariff_type,
            tnuos: false,
            vat_rate: nil,
            energy_tariff_prices: energy_tariff_prices(attribute.input_data['rates'], tariff_type)
          )
        end
      end
    end

    def self.migrate_meter_accounting_tariffs
      ActiveRecord::Base.transaction do
        MeterAttribute.where(
          attribute_type: %w[accounting_tariff accounting_tariff_differential]).active.each do |attribute|
            tariff_type = tariff_type(attribute)
            EnergyTariff.create!(
              ccl: false,
              enabled: true,
              end_date: date_or_nil(attribute.input_data['end_date']),
              meter_type: attribute.meter.meter_type,
              name: attribute.input_data['name'],
              source: :manually_entered,
              start_date: date_or_nil(attribute.input_data['start_date']),
              tariff_holder: attribute.meter.school,
              tariff_type: tariff_type,
              tnuos: false,
              vat_rate: nil,
              energy_tariff_prices: energy_tariff_prices(attribute.input_data['rates'], tariff_type),
              energy_tariff_charges: energy_tariff_charges(attribute.input_data['rates']),
              meters: [attribute.meter]
            )
        end
      end
    end

    def self.migrate_tariff_prices
      ActiveRecord::Base.transaction do
        Meter.dcc.each do |meter|
          meter_attributes = meter.smart_meter_tariff_attributes
          next if meter_attributes.nil?
          #Note: this is an analytics meter attribute hash, not a MeterAttribute record
          meter_attributes[:accounting_tariff_generic].each do |attribute|
            tariff_type = if attribute[:rates][:flat_rate].present?
                            :flat_rate
                          else
                            :differential
                          end

            EnergyTariff.create!(
              ccl: false,
              enabled: true,
              end_date: attribute[:end_date],
              meter_type: meter.meter_type,
              name: attribute[:name],
              source: :dcc,
              start_date: attribute[:start_date],
              tariff_holder: meter.school,
              tariff_type: tariff_type,
              tnuos: false,
              vat_rate: nil,
              energy_tariff_prices: energy_tariff_prices(attribute[:rates], tariff_type, true),
              energy_tariff_charges: energy_tariff_charges(attribute[:rates]),
              meters: [meter]
            )
          end
        end
      end
    end

    #Generic method for creating prices for any type of tariff
    def self.energy_tariff_prices(rates, tariff_type, dcc_tariff = false)
      rates.deep_symbolize_keys!
      if tariff_type == :flat_rate
        [
          EnergyTariffPrice.new(
            start_time: Time.zone.parse('00:00'),
            end_time: Time.zone.parse('23:30'),
            units: 'kwh',
            value: dcc_tariff ? rates[:flat_rate][:rate].to_f : rates[:rate][:rate].to_f
          )
        ]
      elsif dcc_tariff
        #this uses keys of rate0, rate1, rate2
        rate_keys = rates.keys.select {|k| k.to_s.match("rate") }
        rate_keys.map do |rate_key|
          #we have to advance the end time by 30 minutes here, to match
          #later expectations for converting back to meter attribute
          #The EnergyTariff -> meter attribute code rolls the end time back
          #by 30 mins, to create an inclusive range ending at 23:30.
          #rubocop:disable Rails/Date
          EnergyTariffPrice.new(
            start_time: rates[rate_key][:from].to_time,
            end_time: rates[rate_key][:to].to_time.advance(minutes: 30),
            units: 'kwh',
            value: rates[rate_key][:rate]
          )
          #rubocop:enable Rails/Date
        end
      else
        [
          EnergyTariffPrice.new(
            start_time: time_for_rate_type_period(rates, :daytime_rate, :from),
            end_time: time_for_rate_type_period(rates, :daytime_rate, :to),
            units: 'kwh',
            value: rates[:daytime_rate][:rate].to_f
          ),
          EnergyTariffPrice.new(
            start_time: time_for_rate_type_period(rates, :nighttime_rate, :from),
            end_time: time_for_rate_type_period(rates, :nighttime_rate, :to),
            units: 'kwh',
            value: rates[:nighttime_rate][:rate].to_f
          ),
        ]
      end
    end

    #Create charges for accounting tariffs
    def self.energy_tariff_charges(rates)
      rates.deep_symbolize_keys!
      energy_tariff_charges = []
      #iterate over the charges (any non-price related key) add those that
      #have a rate
      ignored = %i[rate daytime_rate nighttime_rate flat_rate]
      rates.each_key do |rate_type|
        next if ignored.include?(rate_type) || rate_type.to_s.match("rate")
        next if rates[rate_type][:rate].blank?
        #charge has :per and :rate values
        charge = rates[rate_type]
        energy_tariff_charges << EnergyTariffCharge.new(
          charge_type: rate_type.to_sym,
          units: charge[:per].to_sym,
          value: charge[:rate].to_f
        )
      end
      energy_tariff_charges
    end

    def self.date_or_nil(val)
      return val if val.is_a?(Date)
      return nil if val.nil? || val.blank?
      Date.parse(val)
    end

    def self.meter_type(attribute)
      meter_types = attribute.meter_types
      return :electricity if meter_types.include?('electricity') || meter_types.include?('aggregated_electricity')
      return :gas if meter_types.include?('gas') || meter_types.include?('aggregated_gas')
      return :solar_pv if meter_types.include?('solar_pv') || meter_types.include?('solar_pv_consumed_sub_meter')
      return :exported_solar_pv if meter_types.include?('exported_solar_pv') || meter_types.include?('solar_pv_exported_sub_meter')
      raise "Unexpected meter type"
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
      if attribute.input_data['rates']['daytime_rate'].present? && attribute.input_data['rates']['daytime_rate']['rate'].present?
        :differential
      else
        :flat_rate
      end
    end

    def self.time_for_rate_type_period(rates, rate_type = :daytime_rate, range = :from)
      return nil unless rates[rate_type].present?
      return nil unless rates[rate_type][range].present?

      period = rates[rate_type][range]

      #meter attributes uses 24:00 as the final period of the day, for its
      #exclusive range. So spot this and return last half-hourly period
      return "00:00" if range == :to && period[:hour] == '24'

      #rubocop:disable Rails/Date
      #use the TimeOfDay class to convert to a time
      time_of_day = TimeOfDay.new(period[:hour].to_i, period[:minutes].to_i).to_time
      #rubocop:enable Rails/Date

      time_of_day.to_s(:time)
    end
  end
end
