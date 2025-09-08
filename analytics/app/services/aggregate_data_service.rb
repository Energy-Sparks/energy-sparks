# frozen_string_literal: true

require_relative 'aggregation_mixin'
require 'benchmark/memory'

# Service responsible for carrying out the data "validation" and "aggregation" processes
# for a +MeterCollection+
#
# The "validation" process involves applying a set of data quality checks and validation
# rules to each meter in the collection. This involves, e.g. substituting for missing or
# bad data. The is delegated to the +ValidateAmrData+ class.
#
# The "aggregation" process involves a variety of steps, including:
#
# - creating new "virtual" meters that hold derived data
#   e.g. solar import/export/self-consumption values)
#
# - creating one ore more "aggregate" meters that combine the individual time-series
#   for each real and virtual meter into a combined series that describes consumption
#   for the whole school.
#
# - processing tariff data so that it can be efficiently applied at runtime
#
# There are various configuration options that can guide this process, e.g. rules
# for combining together meter data, as well configuration that drives individual
# steps (e.g. tariffs, solar panel configuration, etc)
#
# The results of both processes involve modifications to the +MeterCollection+, e.g.
# adding new +Meter+ objects or modifying existing data.
#
# This is a CPU intensive process so generally we aim to cache the results
class AggregateDataService
  include Logging
  include AggregationMixin

  MAX_DAYS_MISSING_DATA = 50

  attr_reader :meter_collection

  def initialize(meter_collection)
    @meter_collection   = meter_collection
    @heat_meters        = @meter_collection.heat_meters
    @electricity_meters = @meter_collection.electricity_meters
  end

  # Convenience method for calling both the validation and aggregation
  # stages.
  def validate_and_aggregate_meter_data
    log 'Validating and Aggregating Meters'
    validate_meter_data
    aggregate_heat_and_electricity_meters

    # Return populated with aggregated data
    @meter_collection
  end

  # Run the validation process on all meters in a +MeterCollection+
  #
  # This is called by the EnergySparks codebase
  def validate_meter_data
    log 'Validating Meters'
    validate_meter_list(@heat_meters)
    validate_meter_list(@electricity_meters)
  end

  # Run the aggregation process on all meters in a +MeterCollection+
  #
  # Should be called after the validation process to ensure that the underlying
  # meter data has first been corrected.
  #
  # - combines multiple meters
  # - potentially over different time periods (e.g. when school structure changes)
  #   - uses smallest range of overlap by default (can be tweaked with MeterAttributes)
  # - synthetic solar polar data for schools we don't have access to meters for (from Sheffield Data)
  # - split out storage heater electricity usage ()
  # - create heating model for gas and storage meters (for predictions into the future)
  #
  # This is called by the EnergySparks codebase
  def aggregate_heat_and_electricity_meters
    log 'Aggregate Meters'
    bm = Benchmark.realtime do
      # aggregate heat meters
      aggregate_heat_meters

      # pre-process, aggregate and post-process electricity meters
      process_electricity_meters

      # notify meter collection that aggregation is complete
      # processes community use opening times
      # carries out clean-up and sets flags on amr data to indicate aggregation process
      # has been completed and caching can be enabled
      @meter_collection.notify_aggregation_complete!
    end

    logger.debug { "Calculated meter aggregation for |#{format('%-35.35s', @meter_collection.name)}| in |#{bm.round(3)}| seconds" }
  end

  private

  def process_electricity_meters
    # Preprocessing step that creates new meters and reorganises existing
    # collection
    process_solar_meters
    aggregate_electricity_meters
    # TODO(PH, 2May2021) - work out why this needs to be after aggregation, or needs any aggregation
    process_storage_heaters
    combine_solar_pv_submeters_into_aggregate if more_than_one_solar_pv_sub_meter?
  end

  # If a school has solar panels, then run the solar aggregation process which
  # results in creation of additional solar meters.
  #
  # The list of meters returned by that process overrides the original list of
  # electricity meters in the collection.
  #
  # TODO: within the service any newly created main_plus_self_consume meter will
  # already have had its costs/co2 information configured. So this may get
  # repeated or overridden in `aggregate_electricity_meters` step that follows.
  def process_solar_meters
    return unless @meter_collection.solar_pv_panels?

    aggregate_solar = AggregateDataServiceSolar.new(@meter_collection)
    processed_meters = aggregate_solar.process_solar_pv_electricity_meters
    # assign references to arrays, as can't be asigned within AggregateDataServiceSolar
    @meter_collection.update_electricity_meters(processed_meters)
    @electricity_meters = processed_meters
  end

  # If a school has storage heaters, then run the storage heater disaggregation
  # process which creates new storage heaters
  def process_storage_heaters
    return unless @meter_collection.storage_heaters?

    adssh = AggregateDataServiceStorageHeaters.new(@meter_collection)
    adssh.disaggregate
  end

  # Returns true if the school has solar panels and multiple electricity meters
  def more_than_one_solar_pv_sub_meter?
    @meter_collection.solar_pv_panels? && @meter_collection.electricity_meters.length > 1
  end

  # Run the validation process on a list of meters.
  #
  # If any meter fails validation then an exception will be raised
  #
  # @param Array list_of_meters an array of +Dashboard::Meter+
  def validate_meter_list(list_of_meters)
    log "Validating #{list_of_meters.length} meters"
    list_of_meters.each do |meter|
      validate_meter = Aggregation::ValidateAmrData.new(meter, MAX_DAYS_MISSING_DATA, @meter_collection.holidays,
                                                        @meter_collection.temperatures)
      validate_meter.validate
    rescue StandardError => e
      add_rollbar_context_if_available(meter, e)
      raise
    end
  end

  def add_rollbar_context_if_available(meter, exception)
    exception.rollbar_context ||= { mpan_mprn: meter.id } if exception.respond_to?(:rollbar_context)
  end

  def combine_solar_pv_submeters_into_aggregate
    aggregate_meter = @meter_collection.aggregated_electricity_meters
    aggregate_sub_meters_by_type(aggregate_meter, @meter_collection.electricity_meters)
  end

  # Updates the +combined_meter+ so that it has the same types of sub_meters as the meters in
  # the provided list.
  #
  # The sub_meters for +combined_meter will each be a new AggregateMeter which aggregate the
  # sub_meters across +meters+. The original meters are retained as a +consistuent_meter+.
  #
  # This basically ensures that the +combined_meter+ combines together data from multiple solar panels and
  # storage heater meters, so it can accurately reflect the overall export, self consumption, mains consumption, etc
  #
  # This is only called for schools that have solar and multiple electricity meters.
  def aggregate_sub_meters_by_type(combined_meter, meters)
    log "Aggregating sub meters for combined meter #{combined_meter} and main electricity meters #{meters.map(&:to_s).join(' ')}"
    sub_meter_types = meters.map { |m| m.sub_meters.keys }.flatten.compact.uniq
    log "Aggregating these types of sub meters: #{sub_meter_types}"

    sub_meters_grouped_by_type = sub_meter_types.map do |sub_meter_type|
      [
        sub_meter_type,
        meters.map { |m| m.sub_meters[sub_meter_type] }.compact
      ]
    end.to_h

    sub_meters_grouped_by_type.each do |sub_meter_type, sub_meters|
      log '---------sub meter aggregation----------' * 2
      log "    Combining type #{sub_meter_type} for #{sub_meters.map(&:to_s).join(' ')}"
      AggregateDataServiceSolar.new(@meter_collection).backfill_meters_with_zeros(sub_meters, combined_meter.amr_data.start_date)
      combined_sub_meter = aggregate_meters(nil, sub_meters, sub_meters[0].fuel_type)
      combined_sub_meter.name = if sub_meter_type == :mains_consume
                                  SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME
                                else
                                  sub_meters[0].name
                                end
      combined_meter.sub_meters[sub_meter_type] = combined_sub_meter
    end
    log "Completed sub meter aggregation for: #{combined_meter}"
    combined_meter.sub_meters.each { |t, m| log "   #{t}: #{m}" }
  end

  # Carry out the aggregation process for gas meters
  #
  # Triggers calculation of carbon emissions and costs for each meter, and
  # creation of the aggregate heat meter.
  def aggregate_heat_meters
    calculate_meters_carbon_emissions_and_costs(@heat_meters, :gas)
    @meter_collection.aggregated_heat_meters = aggregate_main_meters(@meter_collection.aggregated_heat_meters, @heat_meters, :gas)
  end

  def aggregate_electricity_meters
    log '=' * 80
    log 'Aggregating electricity meters'
    calculate_meters_carbon_emissions_and_costs(@electricity_meters, :electricity)
    @meter_collection.aggregated_electricity_meters = aggregate_main_meters(@meter_collection.aggregated_electricity_meters, @electricity_meters, :electricity)
  end

  # Creates a name, id, total floor area and total number of pupils based on
  # metadata associated with a list of meters
  #
  # Names and ids are just concentated, floor area and pupil counts are totalled.
  #
  # @param Array list_of_meters list of meters to process
  def combine_meter_meta_data(list_of_meters)
    meter_names = []
    ids = []
    floor_area = 0
    pupils = 0
    list_of_meters.each do |meter|
      meter_names.push(meter.name)
      ids.push(meter.id)
      if !floor_area.nil? && !meter.floor_area.nil?
        floor_area += meter.floor_area
      else
        floor_area = nil
      end
      if !pupils.nil? && !meter.number_of_pupils.nil?
        pupils += meter.number_of_pupils
      else
        pupils = nil
      end
    end
    name = meter_names.join(' + ')
    id = ids.join(' + ')
    [name, id, floor_area, pupils]
  end

  #
  # Carry out the aggregation process for a list of meters, of a given type
  #
  # @param Dashboard::Meter combined_meter the existing aggregate meter of this type (if there is one)
  # @param Array list_of_meters the list of meters to aggregate
  # @param Symbol type the fuel type being aggregated
  def aggregate_main_meters(combined_meter, list_of_meters, type)
    log "Aggregating #{list_of_meters.length} meters and #{list_of_meters.map { |sm| sm.sub_meters.length }.sum} sub meters"
    aggregate_meters(combined_meter, list_of_meters, type)
  end

  # Aggregates a list of meters with the same fuel type.
  #
  # If there is a single meter in the list, then this is returned directly. It will be
  # treated as the aggregate meter
  #
  # If +combined_meter+ is not nil then this is used as the basis for the aggregation.
  # Any existing floor area, pupil numbers or amr data will be overwritten
  #
  # Otherwise (the common case) creates a new +Dashboard::AggregateMeter+.
  #
  # @param Dashboard::Meter combined_meter the existing aggregate meter, if there is one
  # @param Array list_of_meters the meters to combine
  # @param Symbol fuel_type the fuel type of the meters being aggregated
  # @param boolean copy_amr_data whether to copy the AMR data to the aggregate meter? Looks to be unused now?
  # @return nil if list of meters is nil or empty, a Dashboard::Meter if list contains single entry, the existing combined meter,
  # or a new +Dashboard::AggregateMeter+
  def aggregate_meters(combined_meter, list_of_meters, fuel_type)
    return nil if list_of_meters.nil? || list_of_meters.empty?

    if list_of_meters.length == 1
      meter = list_of_meters.first
      log "Single meter of type #{fuel_type} - using as combined meter from #{meter.amr_data.start_date} to #{meter.amr_data.end_date} rather than creating new one"
      return meter
    end

    log_meter_dates(list_of_meters)

    # Combine the AMR data for the meters to create a new +AmrData+ object
    # Will apply rules that define how the time series are combined
    combined_amr_data = aggregate_amr_data(list_of_meters, fuel_type)

    # Concatenate meter names ids and sum floor area and number of pupils
    combined_name, _, combined_floor_area, combined_pupils = combine_meter_meta_data(list_of_meters)

    # As there is no existing aggregate meter, create a new one
    if combined_meter.nil?
      mpan_mprn = Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(@meter_collection.urn, fuel_type) unless @meter_collection.urn.nil?

      combined_meter = Dashboard::AggregateMeter.new(
        meter_collection: @meter_collection,
        amr_data: combined_amr_data,
        type: fuel_type,
        identifier: mpan_mprn,
        name: combined_name,
        floor_area: combined_floor_area,
        number_of_pupils: combined_pupils,
        constituent_meters: list_of_meters,
        meter_attributes: @meter_collection.pseudo_meter_attributes(Dashboard::Meter.aggregate_pseudo_meter_attribute_key(fuel_type))
      )
    else
      log "Combined meter #{combined_meter.mpan_mprn} already created"
      combined_meter.floor_area = combined_floor_area if combined_meter.floor_area.nil? || combined_meter.floor_area.zero?
      combined_meter.number_of_pupils = combined_pupils if combined_meter.number_of_pupils.nil? || combined_meter.number_of_pupils.zero?
      combined_meter.amr_data = combined_amr_data
    end

    calculate_carbon_emissions_for_meter(combined_meter, fuel_type)

    has_differential_meter = any_component_meter_differential?(list_of_meters, fuel_type, combined_meter.amr_data.start_date, combined_meter.amr_data.end_date) # true if any differential accounting, mostly false atm
    economic_tariffs_differ = !all_economic_tariffs_identical?(list_of_meters) # always false
    has_time_variant_economic_tariffs = any_time_variant_economic_tariffs?(list_of_meters)

    log "Aggregation service time variant #{has_time_variant_economic_tariffs}"

    log "Aggregation test for non-parameterised aggregation: has differential meters = #{has_differential_meter} differing economic tariffs = #{economic_tariffs_differ}"

    set_costs_for_combined_meter(combined_meter, list_of_meters, has_differential_meter || economic_tariffs_differ, has_time_variant_economic_tariffs)

    log "Creating combined meter data #{combined_amr_data.start_date} to #{combined_amr_data.end_date}"
    log "with floor area #{combined_floor_area} and #{combined_pupils} pupils"
    combined_meter
  end

  # Returns true if there are any differential accounting tariffs for any meters in the provided list, within
  # the specified date range.
  def any_component_meter_differential?(list_of_meters, fuel_type, combined_meter_start_date, combined_meter_end_date)
    return false if fuel_type == :gas

    list_of_meters.each do |meter|
      return true if meter.meter_tariffs.any_differential_tariff?(combined_meter_start_date, combined_meter_end_date)
    end
    false
  end

  # Returns true if all economic tariffs for the list of meters are identical.
  #
  # Currently, economic tariffs and time varying tariffs are not set "below" School.
  # So all meters in a school will inherit the same tariffs, so this will always
  # be returning true currently.
  def all_economic_tariffs_identical?(list_of_meters)
    return true if list_of_meters.length == 1

    # Check whether any of the meters have their own tariffs, rather than
    # just sharing the same school/group/system tariffs.
    list_of_meters.none? { |meter| meter.meter_tariffs.meter_tariffs.any? }
  end

  # Returns true if there are any "time varying" economic tariffs. i.e. economic
  # tariffs with different start/end dates.
  def any_time_variant_economic_tariffs?(list_of_meters)
    list_of_meters.each do |meter|
      return true if meter.meter_tariffs.economic_tariffs_change_over_time?
    end
    false
  end

  # Set the tariff information for an aggregate meter
  #
  # Results in setting the economic, current economic and accounting cost tariff schedules
  # for the meter. The flags are used to decide how to precalculate and store the tariffs.
  #
  # @param Dashboard::Meter combined_meter the aggregate meter to which costs will be added
  # @param Array list_of_meters the underlying meters whose costs will be used to calculate tariffs
  # @param boolean has_differing_tariffs whether there are any differential tariffs, or different economic tariffs for the meters
  # @param boolean whether any of the meters has economic tariffs that vary over time
  def set_costs_for_combined_meter(combined_meter, list_of_meters, has_differing_tariffs, has_time_variant_economic_tariffs)
    mpan_mprn = combined_meter.mpan_mprn
    start_date = combined_meter.amr_data.start_date # use combined meter start and end dates to conform with (deprecated) meter aggregation rules
    end_date = combined_meter.amr_data.end_date

    log "Creating economic & accounting cost schedules for combined meter #{mpan_mprn} fuel #{combined_meter.fuel_type} with #{list_of_meters.length} meters from #{start_date} to #{end_date}"

    set_economic_costs(combined_meter, list_of_meters, start_date, end_date, has_differing_tariffs)
    set_current_economic_costs(combined_meter, list_of_meters, start_date, end_date, has_differing_tariffs, has_time_variant_economic_tariffs)

    accounting_costs = AccountingCosts.combine_accounting_costs_from_multiple_meters(combined_meter, list_of_meters, start_date, end_date)
    combined_meter.amr_data.set_accounting_tariff_schedule(accounting_costs)
  end

  def set_economic_costs(combined_meter, list_of_meters, start_date, end_date, has_differing_tariffs)
    combined_meter.mpan_mprn
    if has_differing_tariffs # so need pre aggregated economic costs as kwh to £ no longer additive
      log 'Combining multiple economic costs for a differential tariff meter'
      economic_costs = EconomicCosts.combine_economic_costs_from_multiple_meters(combined_meter, list_of_meters, start_date, end_date)
    else
      log 'Creating a caching economic cost schedule for meter'
      economic_costs = CachingEconomicCosts.new(combined_meter.meter_tariffs, combined_meter.amr_data, combined_meter.fuel_type)
    end
    combined_meter.amr_data.set_economic_tariff_schedule(economic_costs)
  end

  def set_current_economic_costs(combined_meter, list_of_meters, start_date, end_date, has_differing_tariffs, has_time_variant_economic_tariffs)
    if has_time_variant_economic_tariffs
      combined_meter.mpan_mprn
      if has_differing_tariffs # so need pre aggregated economic costs as kwh to £ no longer additive
        log "Combining multiple current economic costs for meter #{combined_meter.fuel_type}"
        economic_costs = EconomicCosts.combine_current_economic_costs_from_multiple_meters(combined_meter, list_of_meters, start_date, end_date)
      else
        log 'Creating a caching current economic cost schedule for meter'
        economic_costs = CachingCurrentEconomicCosts.new(combined_meter.meter_tariffs, combined_meter.amr_data, combined_meter.fuel_type)
      end
      combined_meter.amr_data.set_current_economic_tariff_schedule(economic_costs)
    else
      combined_meter.amr_data.set_current_economic_tariff_schedule_to_economic_tariff
    end
  end

  def log_meter_dates(list_of_meters)
    log 'Combining the following meters'
    list_of_meters.each do |meter|
      log format('%-24.24s %-18.18s %s to %s', meter.display_name, meter.id, meter.amr_data.start_date.to_s, meter.amr_data.end_date)
      aggregation_rules = meter.attributes(:aggregation)
      log "                Meter has aggregation rules #{aggregation_rules}" unless aggregation_rules.nil?
    end
  end

  def log(message)
    logger.info message
    # puts message
  end
end
