module Dashboard
  # meter: holds basic information describing a meter and held hourly AMR data associated with it
  class Meter
    class MissingOriginalMainsMeter < StandardError; end
    include Logging

    # Extra fields - potentially a concern or mix-in
    attr_reader :fuel_type, :meter_collection, :meter_attributes
    attr_reader :storage_heater_setup, :sub_meters, :meter_correction_rules, :model_cache, :partial_meter_coverage, :meter_tariffs, :community_opening_times, :constituent_meters
    attr_accessor :amr_data, :floor_area, :number_of_pupils, :solar_pv_setup, :solar_pv_overrides, :id, :name, :external_meter_id

    # Energy Sparks activerecord fields:
    attr_reader :active, :created_at, :meter_type, :school, :updated_at, :mpan_mprn, :dcc_meter

    # enum meter_type: [:electricity, :gas]

    def initialize(meter_collection:, amr_data:, type:, identifier:, name:,
                   floor_area: nil, number_of_pupils: nil,
                   solar_pv_installation: nil,
                   external_meter_id: nil,
                   dcc_meter: false,
                   meter_attributes: {})
      @amr_data = amr_data
      @meter_collection = meter_collection
      @meter_type = type # think Energy Sparks variable naming is a minomer (PH,31May2018)
      check_fuel_type(fuel_type)
      @fuel_type = type
      set_mpan_mprn_id(identifier)
      @name = name
      @floor_area = floor_area
      @number_of_pupils = number_of_pupils
      @solar_pv_installation = solar_pv_installation
      @meter_correction_rules = []
      @sub_meters = Dashboard::SubMeters.new
      @external_meter_id = external_meter_id
      @dcc_meter = dcc_meter
      set_meter_attributes(meter_attributes)
      @model_cache = AnalyseHeatingAndHotWater::ModelCache.new(self)
      @constituent_meters = [self]
      logger.info "Created new meter: type #{type} id: #{identifier} name: #{name} floor area: #{floor_area} pupils: #{number_of_pupils}"
    end

    def mpxn
      mpan_mprn
    end

    def aggregate_meter?
      false
    end

    def set_meter_attributes(meter_attributes)
      @meter_attributes = meter_attributes
      process_meter_attributes
    end

    def set_mpan_mprn_id(identifier)
      @id = identifier
      @mpan_mprn = identifier.to_i
    end

    def partial_floor_area(start_date = nil, end_date = nil)
      PartialMeterCoverage.total_partial_floor_area(@partial_meter_coverage, start_date, end_date)
    end

    def partial_number_of_pupils(start_date = nil, end_date = nil)
      PartialMeterCoverage.total_partial_number_of_pupils(@partial_meter_coverage, start_date, end_date)
    end

    def meter_floor_area(local_school, start_date = nil, end_date = nil)
      fa = local_school.floor_area(start_date, end_date) * partial_floor_area(start_date, end_date)
      fa.round(0)
    end

    def annual_kwh_estimate
      @annual_kwh_estimate ||= calculate_annual_kwh_estimate
    end

    def calculate_annual_kwh_estimate
      # TODO(PH, 26Aug2021) - consider removing uniq once all of these attributes
      # are against the pseudo meter, rather than the legacy individual meters
      kwh_attr = combined_meter_and_aggregate_attributes(:estimated_period_consumption).uniq
      return Float::NAN if kwh_attr.nil? || kwh_attr.empty?

      kwh_estimate = EstimatePeriodConsumption.new(kwh_attr)
      kwh_estimate.annual_kwh
    end

    def reset_targeting_and_tracking_for_testing
      puts "Resetting target meter for testing #{mpxn}"
      @annual_kwh_estimate = nil
    end

    def enough_amr_data_to_set_target?
      TargetMeter.enough_amr_data_to_set_target?(self)
    end

    def target_attributes
      combined_meter_and_aggregate_attributes(:targeting_and_tracking)
    end

    # there is already a aggregate_meter2? TODO(PH, 10Aug2021) deprecate other version is no errors raised
    def aggregate_meter2?
      return false if meter_collection.aggregate_meter(fuel_type).nil?

      mpxn == meter_collection.aggregate_meter(fuel_type).mpxn
    end

    def self.aggregate_pseudo_meter_attribute_key(fuel_type)
      case fuel_type
      when :storage_heater
        :storage_heater_aggregated
      when :solar_pv
        :solar_pv_consumed_sub_meter
      when :exported_solar_pv
        :solar_pv_exported_sub_meter
      else
        :"aggregated_#{fuel_type}"
      end
    end

    def combined_meter_and_aggregate_attributes(type)
      if aggregate_meter2?
        [
          attributes(type),
          meter_collection.pseudo_meter_attributes(Meter.aggregate_pseudo_meter_attribute_key(fuel_type))[type]
        ].compact.flatten
      else
        attributes(type)
      end
    end

    def target_set?
      !target_attributes.empty?
    end

    def estimated_period_consumption_set?
      combined_meter_and_aggregate_attributes(:estimated_period_consumption).present?
    end

    def meter_number_of_pupils(local_school, start_date = nil, end_date = nil)
      p = local_school.number_of_pupils(start_date, end_date) * partial_number_of_pupils(start_date, end_date)
      p.to_i
    end

    def self.clone_meter_without_amr_data(meter_to_clone)
      Dashboard::Meter.new(
        meter_collection: meter_to_clone.meter_collection,
        amr_data: nil,
        type: meter_to_clone.meter_type,
        name: meter_to_clone.name,
        identifier: meter_to_clone.id,
        floor_area: meter_to_clone.floor_area,
        number_of_pupils: meter_to_clone.number_of_pupils,
        solar_pv_installation: meter_to_clone.solar_pv_setup,
        meter_attributes: meter_to_clone.meter_attributes
      )
    end

    def inspect
      "object_id: #{format('0x00%x', (object_id << 1))}, #{self.class.name}, mpan: #{@mpan_mprn}, fuel_type: #{@fuel_type}"
    end

    def to_s
      dates = amr_data.nil? ? '|no amr data' : "|#{amr_data.start_date} to #{amr_data.end_date}"
      @mpan_mprn.to_s + '|' + @fuel_type.to_s + '|x' + (@amr_data.nil? ? '0' : @amr_data.length.to_s) + dates
    end

    def attributes(type)
      @meter_attributes[type]
    end

    def all_attributes
      @meter_attributes
    end

    def original_meter
      if solar_pv_panels? || storage_heater?
        raise MissingOriginalMainsMeter, "Missing original mains meter for #{mpxn} only got #{sub_meters&.keys}" unless sub_meters.key?(:mains_consume) && !sub_meters[:mains_consume].nil?

        sub_meters[:mains_consume]
      else
        self
      end
    end

    def all_sub_meters
      sub_meters.values.flatten
    end

    def analyse_sub_meters
      puts "Submeters #{sub_meters.keys}"
    end

    def storage_heater?
      !@storage_heater_setup.nil? || @fuel_type == :storage_heater || sub_meters.key?(:storage_heaters) # TODO(PH, 14Sep2019) remove @sstorage_heater_setup test?
    end

    def solar_pv_panels?
      sheffield_simulated_solar_pv_panels? ||
        solar_pv_real_metering? ||
        solar_pv_sub_meters_to_be_aggregated > 0
    end

    def first_solar_pv_panel_installation_date
      if sheffield_simulated_solar_pv_panels?
        @solar_pv_setup.first_installation_date
      elsif solar_pv_real_metering?
        @amr_data.start_date
      end
    end

    def sheffield_simulated_solar_pv_panels?
      !@solar_pv_setup.nil? && @solar_pv_setup.instance_of?(Aggregation::SolarPvPanels)
    end

    def solar_pv_real_metering?
      !@solar_pv_real_metering.nil?
    end

    # num of incoming meters, the aggregation process then implies
    # extra meters - so this method is only valid prior to aggregation
    def solar_pv_sub_meters_to_be_aggregated
      return 0 if attributes(:solar_pv_mpan_meter_mapping).nil?

      attributes(:solar_pv_mpan_meter_mapping).length
    end

    def non_heating_only?
      function_includes?(:hotwater_only, :kitchen_only)
    end

    def kitchen_only?
      # wouldn't expect weekend or holiday use
      function_includes?(:kitchen_only)
    end

    def hot_water_only?
      function_includes?(:hotwater_only)
    end

    def heating_only?
      function_includes?(:heating_only)
    end

    def up_to_one_year_model_period
      start_date = [amr_data.end_date - 364, amr_data.start_date].max
      SchoolDatePeriod.new(:up_to_1_year_meter, 'Current Year', start_date, amr_data.end_date)
    end

    def heating_model(period = up_to_one_year_model_period, model_type = :best, non_heating_model_type = nil)
      @model_cache.create_and_fit_model(model_type, period, false, non_heating_model_type)
    end

    def meter_collection
      school || @meter_collection
    end

    def solar_pv
      meter_collection.solar_pv
    end

    def heat_meter?
      %i[gas storage_heater aggregated_heat].include?(fuel_type)
    end

    def electricity_meter?
      %i[electricity solar_pv aggregated_electricity].include?(fuel_type)
    end

    def insert_correction_rules_first(rules)
      @meter_correction_rules = rules + @meter_correction_rules
    end

    # Matches ES AR version
    def display_name
      name.present? ? "#{mpan_mprn} - #{name}" : mpan_mprn.to_s
    end

    def name_or_mpan_mprn
      name.present? ? name : mpan_mprn.to_s
    end

    # Default series name for this meter when displayed on a chart
    def series_name
      name.present? ? name : mpan_mprn.to_s
    end

    # Used to create a qualified series name for charts, when 2 meters for
    # this school have the same name.
    def qualified_series_name
      name.present? ? "#{name} (#{mpan_mprn})" : mpan_mprn.to_s
    end

    def analytics_name
      return mpan_mprn.to_s unless name.present?

      bracketed_text = name.include?(mpan_mprn.to_s) ? 'MPAN' : mpxn.to_s
      "#{name} (#{bracketed_text})"
    end

    def synthetic_mpan_mprn?
      mpan_mprn > 60_000_000_000_000
    end

    def aggregate_meter?
      # TODO(PH, 14Sep2019) - Make 90000000000000 etc. masks constants
      aggregate = 90_000_000_000_000 & mpan_mprn > 0 || 80_000_000_000_000 & mpan_mprn > 0
      # TODO(PH, 10Aug2021) deprecate in favour of aggregate_meter2? if continues to work
      raise StandardError, 'Unexpected inconsistency in aggregate meter logic see aggregate_meter2?' if aggregate != aggregate_meter2?

      aggregate
    end

    def self.synthetic_combined_meter_mpan_mprn_from_urn(urn, fuel_type, group_number = 0)
      if %i[electricity aggregated_electricity].include?(fuel_type)
        90_000_000_000_000 + urn.to_i
      elsif %i[gas aggregated_heat].include?(fuel_type)
        80_000_000_000_000 + urn.to_i
      elsif fuel_type == :storage_heater # suspect as same number as solar_pv; TODO(PH, 14Sep2019)
        70_000_000_000_000 + urn.to_i
      elsif fuel_type == :solar_pv
        70_000_000_000_000 + urn.to_i + 1_000_000_000_000 * group_number
      elsif fuel_type == :exported_solar_pv
        60_000_000_000_000 + urn.to_i + 1_000_000_000_000 * group_number
      else
        raise EnergySparksUnexpectedStateException.new, "Unexpected fuel_type #{fuel_type}"
      end
    end

    def self.synthetic_aggregate_generation_meter(base_mpan)
      mpan = base_mpan.to_i
      prefix = (mpan / 10_000_000_000_000) * 10_000_000_000_000
      20_000_000_000_000 + (mpan - prefix)
    end

    def self.synthetic_mpan_mprn(mpan_mprn, type)
      mpan_mprn = mpan_mprn.to_i
      case type
      when :storage_heater_only, :storage_heater_disaggregated_storage_heater
        70_000_000_000_000 + mpan_mprn
      when :electricity_minus_storage_heater, :storage_heater_disaggregated_electricity
        75_000_000_000_000 + mpan_mprn
      when :solar_pv
        80_000_000_000_000 + mpan_mprn
      else
        raise EnergySparksUnexpectedStateException.new("Unexpected type #{type} for modified mpan/mprn")
      end
    end

    # Sets the default cost schedules for this meter, allowing calculation of £/co2 values
    def set_tariffs
      set_economic_tariff
      set_current_economic_tariff
      set_accounting_tariff
    end

    private

    def set_economic_tariff
      logger.info "Creating an economic cost schedule for #{mpan_mprn} #{fuel_type}"
      @amr_data.set_economic_tariff_schedule(CachingEconomicCosts.new(@meter_tariffs, @amr_data, fuel_type))
    end

    def set_current_economic_tariff
      logger.info "Creating current economic cost schedule for meter #{name}"
      if @meter_tariffs.economic_tariffs_change_over_time?
        @amr_data.set_current_economic_tariff_schedule(CachingCurrentEconomicCosts.new(@meter_tariffs, @amr_data, fuel_type))
      else
        # there no computational benefit in doing this,
        # given the tariff for amr_data.end_date is always re-looked up rather than cached
        # but perhaps a slight memory benefit
        @amr_data.set_current_economic_tariff_schedule_to_economic_tariff
      end
    end

    def set_accounting_tariff
      logger.info "Creating accounting cost schedule for meter #{mpan_mprn} #{fuel_type}"
      @amr_data.set_accounting_tariff_schedule(CachingAccountingCosts.new(@meter_tariffs, @amr_data, fuel_type))
    end

    def process_meter_attributes
      @storage_heater_setup     = StorageHeater.new(attributes(:storage_heaters)) if @meter_attributes.key?(:storage_heaters)
      @solar_pv_setup           = Aggregation::SolarPvPanels.create(self, :solar_pv)
      @solar_pv_overrides       = Aggregation::SolarPvPanels.create(self, :solar_pv_override)
      @solar_pv_real_metering   = true if @meter_attributes.key?(:solar_pv_mpan_meter_mapping)
      @partial_meter_coverage ||= PartialMeterCoverage.new(attributes(:partial_meter_coverage))
      @meter_tariffs = GenericTariffManager.new(self)
    end

    def check_fuel_type(fuel_type)
      raise EnergySparksUnexpectedStateException.new("Unexpected fuel type #{fuel_type}") if %i[electricity gas].include?(fuel_type)
    end

    def function_includes?(*function_list)
      function = attributes(:function)
      !function.nil? && !(function_list & function).empty?
    end
  end
end
