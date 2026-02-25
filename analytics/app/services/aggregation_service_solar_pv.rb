# frozen_string_literal: true

# Service responsible for aggregating solar data. Coordinates processing of real
# metered data and the creation of synthetic solar meters
#
class AggregateDataServiceSolar
  include Logging
  include AggregationMixin

  attr_reader :meter_collection

  def initialize(meter_collection)
    @meter_collection   = meter_collection
    @electricity_meters = @meter_collection.electricity_meters
    @electricity_meter_names = find_electricity_meter_names
  end

  # Process the electricity meters in the collection, returning an updated
  # list of meters
  #
  # The list will either consist of original meters or a new "mains_plus_self_consume" meter
  def process_solar_pv_electricity_meters
    logger.debug { '=' * 80 }
    electricity_meters_only = @electricity_meters.select { |meter| meter.fuel_type == :electricity }

    processed_electricity_meters = electricity_meters_only.map do |mains_electricity_meter|
      if mains_electricity_meter.solar_pv_panels?
        # create a SolarMeterMap, removing any real solar meters from the meter collection for this meter
        pv_meter_map = setup_meter_map(mains_electricity_meter)
        process_solar_pv_electricity_meter(pv_meter_map)
      else
        reference_as_sub_meter_for_subsequent_aggregation(mains_electricity_meter)
        mains_electricity_meter
      end
    end
    logger.debug { '=' * 80 }
    processed_electricity_meters
  end

  # Takes a list of meters and, if they have a shorter range of data than the
  # provided mains meter, backfills them with zero readings so all the meters
  # have the same range
  #
  # @param Array [meters] the list of meters to process
  # @param Date [mains_meter_start_date] the start date for the main meter data
  def backfill_meters_with_zeros(meters, mains_meter_start_date)
    meters.each do |meter|
      backfill_meter_with_zeros(meter, mains_meter_start_date, meter.amr_data.start_date - 1)
    end
  end

  private

  # Create a hash of mpan to name for all electricity meters
  def find_electricity_meter_names
    @electricity_meters.map { |electricity_meter| [electricity_meter.mpan_mprn, electricity_meter.name] }.to_h
  end

  # Carry out the aggregation process for a single meter, using the information
  # configured in its SolarMeterMap.
  #
  # The map will have at least a `:mains_consume` entry (which is the original)
  # electricity meter. It may have additional references, e.g. generation, export
  # depending on what was configured in the solar_pv_mapping attribute (if there is
  # real solar metering).
  #
  # Ends up returning a new meter which represents the mains consumption plus
  # any self consumed solar generation. This meter will have sub meters that reference
  # the underlying export, generation, mains consumption meters.
  #
  # @param SolarMeterMap [pv_meter_map] the map.
  # @param Dashboard:Meter representing the mains plus self consumption meter
  def process_solar_pv_electricity_meter(pv_meter_map)
    logger.debug { "Aggregation service: processing mains meter #{pv_meter_map[:mains_consume]} with solar pv" }
    print_meter_map(pv_meter_map)

    aggregate_multiple_generation_meters(pv_meter_map) if pv_meter_map.number_of_generation_meters > 1

    # If we have real metered solar generation data, but no export meters, then
    # create export and self-consumption meters
    if !pv_meter_map[:generation].nil? && pv_meter_map[:export].nil?
      create_export_self_consumption_where_real_generation_data_but_no_export(pv_meter_map)
    # If we don't have any metering of solar, then create synthetic solar data
    elsif pv_meter_map[:mains_consume].sheffield_simulated_solar_pv_panels?
      create_solar_pv_sub_meters_using_sheffield_pv_estimates(pv_meter_map)
    # Otherwise we have both metering for both the solar generation and export
    else
      # Backfill meters with zero readings, then truncate range to match the mains
      # consumption meter
      clean_pv_meter_start_and_end_dates(pv_meter_map)

      create_export_and_calculate_self_consumption_meters(pv_meter_map)

      # Process any overrides for bad data
      fix_missing_or_bad_meter_data(pv_meter_map)
    end

    create_mains_plus_self_consume_meter(pv_meter_map)

    raise EnergySparksUnexpectedStateException, 'Not all solar pv meters assigned' unless pv_meter_map.all_required_key_values_non_nil?

    # Override the names of meters assigned during the aggregation process
    assign_meter_names(pv_meter_map)

    # Set the schedule of cost + co2 data for each meter in the map
    calculate_carbon_emissions_and_costs(pv_meter_map)

    # aligns the start/end dates of all the meters in the map, so they have
    # identical ranges
    normalise_date_ranges_of_sub_meters(pv_meter_map)

    # assigns the mains_consume, self_consume, export and generation meters
    # as sub meters of the mains_plus_self_consume meter
    mains_plus_self_consume_meter = assign_meters_and_sub_meters(pv_meter_map)

    consumption_meter = mains_plus_self_consume_meter

    # DEBUG
    print_meter_map(pv_meter_map)
    print_final_setup(mains_plus_self_consume_meter)

    consumption_meter
  end

  # Processes any `solar_pv_override` meter attributes for the mains consumption
  # meter in the map, to replace the generation, export or self consumption values
  # (as required) within a data range with modelled solar data, using the Sheffield dataset
  #
  # See +Aggregation::SolarPvPanels.process+
  #
  # This is a data correction step that happens outside of the normal aggregation validation
  # process.
  def fix_missing_or_bad_meter_data(pv_meter_map)
    return unless !pv_meter_map[:mains_consume].nil? && !pv_meter_map[:mains_consume].solar_pv_overrides.nil?

    pv_meter_map[:mains_consume].solar_pv_overrides.process(pv_meter_map, @meter_collection)
  end

  def not_a_meter?(meter)
    meter.nil? || meter.is_a?(Array)
  end

  # Debugging
  def print_meter_map(pv_meter_map)
    logger.debug { 'PV Meter map:' }
    pv_meter_map.each do |meter_type, meter|
      if meter.is_a?(Array)
        logger.debug { "    #{meter_type} => #{meter.map { |m| format_meter(m) }.join('; ')}" }
      else
        logger.debug { "    #{format('%-25.25s', meter_type)} -> #{format_meter(meter)}" }
      end
    end
  end

  # Debugging
  def format_meter(meter)
    meter.nil? ? 'nil' : "#{format('%-60.60s', meter.to_s)} = #{meter.amr_data.total.round(0)} kWh"
  end

  # Debugging
  def print_final_setup(meter)
    logger.debug { "Final meter setup for #{meter} total #{meter.amr_data.total.round(0)}" }
    meter.sub_meters.each do |meter_type, sub_meter|
      logger.debug { "    sub_meter: #{meter_type} => #{sub_meter} name #{sub_meter.name} total #{sub_meter.amr_data.total.round(0)}" }
    end
  end

  # Results in the meter having a reference to itself as a mains consumption meter
  # in its Dashboard::Submeters hash
  def reference_as_sub_meter_for_subsequent_aggregation(mains_electricity_meter)
    logger.debug { "Referencing mains consumption meter #{mains_electricity_meter.mpan_mprn} without pv as sub meter for subsequent aggregation" }
    mains_electricity_meter.sub_meters[:mains_consume] = mains_electricity_meter
  end

  def clean_pv_meter_start_and_end_dates(pv_meter_map)
    backfill_existing_meters_with_zeros(pv_meter_map)
    truncate_to_mains_meter_dates(pv_meter_map)
  end

  # Ensure that the value of the AMRdata for this meter is all negative
  def negate_sign_of_export_meter_data(pv_meter_map)
    pv_meter_map[:export].amr_data = invert_export_amr_data_if_positive(pv_meter_map[:export].amr_data)
  end

  # Creates an export meter and self consumption meters, if needed
  # Ensures amr data for any existing export meter is negative.
  #
  # @returns Dashboard::Meter the self consumption meter
  def create_export_and_calculate_self_consumption_meters(pv_meter_map)
    if pv_meter_map[:export].nil?
      # TODO: if we've got here, then the new export meter isn't added to the map?
      create_export_meter(pv_meter_map)
    else
      negate_sign_of_export_meter_data(pv_meter_map)
    end
    create_and_calculate_self_consumption_meter(pv_meter_map) if pv_meter_map[:self_consume].nil?
  end

  # Create an export meter, copying some configuration from the main consumption meter in the map
  #
  # TODO(PH, 20Nov2020) - untested
  # TODO there's duplicate/overlapping code between the aggregation_mixin and solar_pv_panels that
  # achieve the same thing
  def create_export_meter(pv_meter_map)
    date_range = pv_meter_map[:mains_consume].amr_data.date_range
    logger.debug { "Creating empty export meter between #{date_range.first} and #{date_range.last}" }
    amr_data = AMRData.create_empty_dataset(:exported_solar_pv, date_range.first, date_range.last, 'SOLE')
    @meter_collection.create_modified_copy_of_meter(
      original: pv_meter_map[:mains_consume],
      amr_data: amr_data,
      meter_type: :exported_solar_pv,
      identifier: Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(@meter_collection.urn, :exported_solar_pv),
      name: SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
      pseudo_meter_key: :solar_pv_exported_sub_meter
    )
  end

  # Creates a self consumption meter based on real metering of the
  # solar generation and export. The self consumption meter is added
  # to the meter map
  #
  # self-consumption = generation - export
  #
  # The values are added in this method, so this relies on the export
  # values having been made negative in previous step.
  def create_and_calculate_self_consumption_meter(pv_meter_map)
    logger.debug { 'Creating and calculating self consumption meter' }
    # take the mains consumption, export and solar pv production
    # meter readings and calculate self consumption =
    # self_consumption = solar pv production - export
    onsite_consumpton_amr_data = aggregate_amr_data(
      [pv_meter_map[:generation], pv_meter_map[:export]],
      :electricity,
      ignore_rules: true,
      zero_negative: true
    )
    pv_meter_map[:self_consume] = @meter_collection.create_modified_copy_of_meter(
      original: pv_meter_map[:mains_consume],
      amr_data: onsite_consumpton_amr_data,
      meter_type: :solar_pv,
      identifier: Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(@meter_collection.urn, :solar_pv),
      name: SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME,
      pseudo_meter_key: :solar_pv_consumed_sub_meter
    )
  end

  # Adds a `mains_plus_self_consume` meter to the map, which consists of the
  # mains consumption plus the self consumption data.
  #
  # The new meter has the same mpan as the mains consumption meter.
  def create_mains_plus_self_consume_meter(pv_meter_map)
    consumpton_amr_data = aggregate_amr_data(
      [pv_meter_map[:self_consume], pv_meter_map[:mains_consume]],
      :electricity,
      ignore_rules: true
    )

    pv_meter_map[:mains_plus_self_consume] = @meter_collection.create_modified_copy_of_meter(
      original: pv_meter_map[:mains_consume],
      amr_data: consumpton_amr_data,
      meter_type: :electricity,
      identifier: pv_meter_map[:mains_consume].mpan_mprn,
      name: pv_meter_map[:mains_consume].name
    )
  end

  def aggregate_multiple_generation_meters(pv_meter_map)
    logger.debug { 'Aggregating multiple solar pv generation meters' }

    generation_meters = pv_meter_map.select { |type, meter| SolarMeterMap.generation_meters.include?(type) && !meter.nil? }.values

    logger.debug { "Aggregating these generation meters #{generation_meters.map(&:to_s).join(' + ')}" }

    mpan = Dashboard::Meter.synthetic_aggregate_generation_meter(pv_meter_map[:generation].mpan_mprn)

    generation_amr_data = aggregate_amr_data_between_dates(
      generation_meters,
      :solar_pv,
      generation_meters.map { |m| m.amr_data.start_date }.min,
      generation_meters.map { |m| m.amr_data.end_date }.max,
      mpan
    )

    generation_meter = @meter_collection.create_modified_copy_of_meter(
      original: pv_meter_map[:generation],
      amr_data: generation_amr_data,
      meter_type: :solar_pv,
      identifier: mpan,
      name: pv_meter_map[:generation].name
    )

    logger.debug { "Created aggregate generation meter #{generation_meter} #{generation_meter.amr_data.total.round(0)}" }

    # hide constituent generation meters
    pv_meter_map.set_nil_value(SolarMeterMap.generation_meters)
    generation_mpans = generation_meters.map { |m1| m1.mpan_mprn.to_s }
    @meter_collection.electricity_meters.delete_if { |m| generation_mpans.include?(m.mpan_mprn.to_s) }
    pv_meter_map[:generation] = generation_meter
    pv_meter_map[:generation_meter_list] = generation_meters
  end

  def calculate_carbon_emissions_and_costs(pv_meter_map)
    pv_meter_map.each_value do |meter|
      calculate_meter_carbon_emissions_and_costs(meter, :electricity) unless not_a_meter?(meter)
    end
  end

  def normalise_date_ranges_of_sub_meters(pv_meter_map)
    meters = %i[mains_consume self_consume export generation mains_plus_self_consume].map { |meter_type| pv_meter_map[meter_type] }
    start_date = meters.map { |m| m.amr_data.start_date }.max
    end_date   = meters.map { |m| m.amr_data.end_date }.min
    logger.debug { "Reducing sub meter date ranges to between #{start_date} and #{end_date}" }
    meters.each do |meter|
      meter.amr_data.set_start_date(start_date)
      meter.amr_data.set_end_date(end_date)
    end
  end

  def assign_meters_and_sub_meters(pv_meter_map)
    %i[mains_consume self_consume export generation].each do |meter_type|
      pv_meter_map[:mains_plus_self_consume].sub_meters[meter_type] = pv_meter_map[meter_type]
    end
    pv_meter_map[:mains_plus_self_consume]
  end

  # Override the names of meters in the map
  # See SolarMeterMap.meter_type_to_name_map
  def assign_meter_names(pv_meter_map)
    pv_meter_map.each do |meter_type, meter|
      next if not_a_meter?(meter)

      if meter_type == :mains_plus_self_consume
        school_meter_name = @electricity_meter_names[meter.mpan_mprn]
        meter.name = if school_meter_name.present?
                       I18n.t('aggregation_service_solar_pv.mains_plus_self_consume_name', meter_name: school_meter_name) + " (#{meter.mpan_mprn})"
                     else
                       I18n.t('aggregation_service_solar_pv.mains_plus_self_consume_name', meter_name: meter.mpan_mprn.to_s)
                     end
      else
        meter.name = SolarMeterMap.meter_type_to_name_map[meter_type]
      end
    end
  end

  def backfill_existing_meters_with_zeros(pv_meter_map)
    pv_meter_map.each do |meter_type, meter|
      next if not_a_meter?(meter) || meter_type == :mains_consume

      mpan_mapping_start_date = earliest_mpan_mapping_attribute(pv_meter_map[:mains_consume], meter_type)
      mains_meter_start_date  = pv_meter_backfill_start_date(pv_meter_map[:mains_consume])
      backfill_meter_with_zeros(meter, mains_meter_start_date, mpan_mapping_start_date - 1)
    end
  end

  # Truncates every meter in the map to the date ranges of the mains
  # consumption meter
  def truncate_to_mains_meter_dates(pv_meter_map)
    mains_electricity_meter = pv_meter_map[:mains_consume]
    pv_meter_map.each do |meter_type, meter|
      next if not_a_meter?(meter) || meter_type == :mains_consume

      logger.debug { "Mains meter start date #{mains_electricity_meter.amr_data.start_date} pv meter  #{meter.mpan_mprn} #{meter.fuel_type} start date #{meter.amr_data.start_date}" }
      raise EnergySparksUnexpectedStateException, "Meter should have been backfilled to #{mains_electricity_meter.amr_data.start_date} but set to #{meter.amr_data.start_date}" if mains_electricity_meter.amr_data.start_date < meter.amr_data.start_date

      if meter.amr_data.start_date < mains_electricity_meter.amr_data.start_date
        logger.debug { "Truncating meter #{meter.mpan_mprn} to start date of electricity meter #{mains_electricity_meter.amr_data.start_date}" }
        meter.amr_data.set_start_date(mains_electricity_meter.amr_data.start_date)
      end
      if meter.amr_data.end_date > mains_electricity_meter.amr_data.end_date
        logger.debug { "Truncating meter #{meter.mpan_mprn} to end date of electricity meter #{mains_electricity_meter.amr_data.end_date}" }
        meter.amr_data.set_end_date(mains_electricity_meter.amr_data.end_date)
      end
    end
  end

  def pv_meter_backfill_start_date(mains_electricity_meter)
    mains_electricity_meter.amr_data.start_date
  end

  # creates synthetic solar pv metering using 1/2 hour yield data from Sheffield University
  # for schools where we don't have real metering
  def create_solar_pv_sub_meters_using_sheffield_pv_estimates(pv_map)
    logger.debug { 'Creating solar PV data from Sheffield PV feed' }

    pv_map[:mains_consume].solar_pv_setup.process(pv_map, @meter_collection)

    negate_sign_of_export_meter_data(pv_map) # defensive, probably not needed
  end

  def invert_export_amr_data_if_positive(amr_data)
    # using 0.10000000001 as LCC seems to have lots of 0.1 values?????
    histo = amr_data.histogram_half_hours_data([-0.10000000001, +0.10000000001])
    negative = histo[0] > (histo[2] * 10) # 90%
    logger.debug do
      message = negative ? 'is negative therefore leaving unchanged' : 'is positive therefore inverting to conform to internal convention'
      "Export amr pv data #{message}"
    end
    amr_data.scale_kwh(-1.0) unless negative
    amr_data
  end

  # the mpan mapping is used to override the start date of the incoming data
  # if necessary e.g. in the circumstance where the metering was incorrect
  # during the installation phase, so anything before that is deemed to be
  # zero, or overridden by the synthetic Sheffield data if set
  def earliest_mpan_mapping_attribute(mains_meter, meter_type)
    mains_meter.attributes(:solar_pv_mpan_meter_mapping).map do |mpan_pv_map|
      mpan_pv_map[SolarMeterMap.meter_attribute_key(meter_type)].nil? ? nil : meter_start_date(mpan_pv_map)
    end.compact.min
  end

  def meter_start_date(mpan_pv_map)
    if mpan_pv_map[:start_date].nil?
      # TODO(PH, 18Nov2020) - legacy, remove once now mandatory mapping :start_date set
      mapped_meters = SolarMeterMap::MPAN_KEY_MAPPINGS.values.compact.map do |type|
        @electricity_meters.detect { |m| m.mpan_mprn.to_s == mpan_pv_map[type] }
      end.compact
      mapped_meters.map { |meter| meter.amr_data.start_date }.max
    else
      mpan_pv_map[:start_date]
    end
  end

  # to save endless checking downstream in the analysis code
  # backfill pv meters which don't extend backwards as far as the
  # mains electricity meter with zeros
  def backfill_meter_with_zeros_deprecated(meter, mains_meter_start_date, _mpan_mapping_start_date)
    return if mains_meter_start_date >= meter.amr_data.start_date

    logger.debug { "Backfilling pv meter #{meter.mpan_mprn} with zeros between #{mains_meter_start_date} and #{meter.amr_data.start_date}" }
    (mains_meter_start_date..meter.amr_data.start_date).each do |date|
      meter.amr_data.add(date, OneDayAMRReading.zero_reading(meter.id, date, 'BKPV'))
    end
  end

  # to save endless checking downstream in the analysis code
  # backfill pv meters which don't extend backwards as far as the
  # mains electricity meter with zeros
  def backfill_meter_with_zeros(meter, start_date, end_date)
    return if start_date >= meter.amr_data.start_date

    logger.debug { "Backfilling pv meter #{meter.mpan_mprn} with zeros between #{start_date} and #{end_date}" }
    (start_date..end_date).each do |date|
      meter.amr_data.add(date, OneDayAMRReading.zero_reading(meter.id, date, 'BKPV'))
    end
  end

  # Create a SolarMeterMap that will be used to hold references to a range of different
  # types of solar meter, e.g. export, generation, self consumption
  #
  # The provided mains meter is configured as the mains consumption meter.
  # Other meters are populated based on the `solar_pv_mpan_meter_mapping` meter
  # attribute if available.
  #
  # Will result in any mapped meters being removed from the electricity meter
  # collection for the school, as they need special processing and cannot be
  # treated as a mains consumption meter
  #
  # @param Dashboard::Meter mains_electricity_meter an electricity meter
  # @returns SolarMeterMap
  def setup_meter_map(mains_electricity_meter)
    pv_meter_map = SolarMeterMap.instance
    pv_meter_map[:mains_consume] = mains_electricity_meter
    map_real_meters(pv_meter_map)
    pv_meter_map
  end

  # Populates a SolarMeterMap instance using the `solar_pv_mpan_meter_mapping` meter
  # attribute configuration. If the mapping includes start/end dates then the
  # meters will be truncated to align with those dates, so any data outside of that
  # range will be ignored
  #
  # Any meters referenced in that config will be added to the map as the right
  # type, e.g. as an export meter, and will be removed from the list of electricity
  # meters in the meter collection.
  #
  #
  #
  # The meters will later receive special processing
  # @param SolarMeterMap [pv_meter_map] the instance to populate
  def map_real_meters(pv_meter_map)
    mappings = pv_meter_map[:mains_consume].attributes(:solar_pv_mpan_meter_mapping)
    return if mappings.nil?

    mappings.each do |map|
      SolarMeterMap.meter_mappings(map).each do |meter_attribute_key, mpan|
        meter = @meter_collection.electricity_meters.find { |meter1| meter1.mpan_mprn.to_s == mpan }
        @meter_collection.electricity_meters.delete_if { |m| m.mpan_mprn.to_s == mpan.to_s }
        pv_meter_map[SolarMeterMap.meter_type(meter_attribute_key)] = meter
        truncate_meter_dates(meter, map)
      end
    end
  end

  # Truncates the AMR data associated with a meter to align with the start and
  # end dates (both optional) configured in a `solar_pv_mpan_meter_mapping` attribute
  def truncate_meter_dates(meter, map)
    truncate_start_date(meter, map[:start_date])
    truncate_end_date(meter, map[:end_date])
  end

  # Carries out solar aggregation where we have:
  # - a mains consumption meter
  # - metered solar generation data
  #
  # Optionally will also add synthetic solar data, e.g. if we don't have a
  # fully metered date range for the panels. Will also apply any overrides that
  # have been configured for periods of bad/poor data from the generation meter
  #
  # @param SolarMeterMap [pv_meter_map] the pv meter configuration
  def create_export_self_consumption_where_real_generation_data_but_no_export(pv_meter_map)
    am = pv_meter_map[:generation].amr_data

    # DEBUGGING, Ignore/remove
    if @apply_scaling_factor_for_debug
      scale_factor = 1.0
      logger.debug { '*' * 50 }
      logger.debug { "Scaling data by a factor of #{scale_factor} " }
      pv_meter_map[:generation].amr_data.scale_kwh(scale_factor, date1: am.start_date, date2: am.end_date)
      logger.debug { '*' * 50 }
    end

    # Use a customised sub-class of SolarPVPanels
    # Pads out the generation meter to match ranges of the mains consumption
    # meter, then creates export and self-consumption from the consumption and
    # generation data
    #
    # real generation data but no export, so calculate
    Aggregation::SolarPvPanelsMeteredProduction.new.process(pv_meter_map, @meter_collection)

    # Ensure meter dates align
    truncate_to_mains_meter_dates(pv_meter_map)

    # If a school also has sheffield solar attributes configured, then
    # this might result in the real metered data being extended with
    # additional synthetic data, e.g. if the panels installed at a later date
    #
    # potentially override or extend with Sheffield Synthetic
    create_solar_pv_sub_meters_using_sheffield_pv_estimates(pv_meter_map) if pv_meter_map[:mains_consume].sheffield_simulated_solar_pv_panels?

    # ...and with solar override attributes as well
    fix_missing_or_bad_meter_data(pv_meter_map)
  end

  # Set the start date for the AMRData associated with the meter
  def truncate_start_date(meter, start_date)
    return if start_date.nil?

    if start_date < meter.amr_data.start_date
      logger.debug { "Error: solar_pv_mpan_meter_mapping meter attribute start_date #{start_date} < meter start_date #{meter.amr_data.start_date}" }
    elsif start_date > meter.amr_data.end_date
      logger.debug { "Error: solar_pv_mpan_meter_mapping meter attribute start_date #{start_date} > meter end_date #{meter.amr_data.end_date}" }
    else
      logger.debug { "Warning: overriding amr start date to #{start_date} for meter #{meter.mpan_mprn}" }
      meter.amr_data.set_start_date(start_date)
    end
  end

  # Set the end date for the AMRData associated with the meter
  def truncate_end_date(meter, end_date)
    return if end_date.nil?

    if end_date > meter.amr_data.end_date
      logger.debug { "Error: solar_pv_mpan_meter_mapping meter attribute end_date #{end_date} > meter end_date #{meter.amr_data.end_date}" }
    elsif end_date < meter.amr_data.start_date
      logger.debug { "Error: solar_pv_mpan_meter_mapping meter attribute end_date #{end_date} < meter start_date #{meter.amr_data.start_date}" }
    else
      logger.debug { "Warning: overriding amr end date to #{end_date} for meter #{meter.mpan_mprn}" }
      meter.amr_data.set_end_date(end_date)
    end
  end
end
