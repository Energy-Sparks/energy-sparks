# creates new solar pv panel data synthetically from Sheffield University sourced data
# and can also use this to override real solar pv metering when it goes wrong via meter attributes
# uses the SolarPV, SolarPVOverrides, SolarPVMeterMapping meter attributes for configuration
class SolarPVPanels
  include Logging
  attr_reader :meter_attributes_config, :real_production_data

  MAINS_ELECTRICITY_CONSUMPTION_INCLUDING_ONSITE_PV = 'Electricity consumed including onsite solar pv consumption'.freeze
  SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME = 'Electricity consumed from solar pv'.freeze
  SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME = 'Exported solar electricity (not consumed onsite)'.freeze
  ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME = 'Electricity consumed from mains'.freeze
  SOLAR_PV_PRODUCTION_METER_NAME = 'Solar PV Production'

  SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME_I18N_KEY = 'electricity_consumed_from_solar_pv'.freeze
  SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME_I18N_KEY = 'exported_solar_electricity'.freeze
  ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME_I18N_KEY = 'electricity_consumed_from_mains'.freeze

  SUBMETER_TYPES = [
    ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME,
    SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
    SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME
  ]

  def self.create(meter, attribute_name)
    return unless meter.meter_attributes.key?(attribute_name)

    new(meter.meter_attributes[attribute_name], meter.meter_collection.solar_pv,
        override_default: attribute_name == :solar_pv)
  end

  # @param [Hash] meter_attributes_config the :solar_pv meter attributes to process
  # @param [SolarPV] synthetic_sheffield_solar_pv_yields the Sheffield Solar data for this school
  def initialize(meter_attributes_config, synthetic_sheffield_solar_pv_yields, override_default: true)
    unless meter_attributes_config.nil?
      @solar_pv_panel_config = SolarPVPanelConfiguration.new(meter_attributes_config, override_default)
    end
    @synthetic_sheffield_solar_pv_yields = synthetic_sheffield_solar_pv_yields
    @debug_date_range = nil # Date.new(2021, 6, 18)..Date.new(2021, 6, 19) # Date.new(2021, 6, 1)..Date.new(2021, 6, 7) || nil
    @real_production_data = false
  end

  def first_installation_date
    @solar_pv_panel_config.first_installation_date
  end

  # Main entry point into the service, called as part of the aggregation process.
  # Creates new meters and synthetic data as required.
  #
  # The provided SolarMeterMap might be empty (other than the mains consumption meter) or
  # may contain entries from the `solar_pv_mpan_meter_mapping` meter attribute if
  # there is actual metered solar data. In this case we might end up overriding that
  # specific date ranges within that data if configured to do so.
  #
  # @param [SolarMeterMap] pv_meter_map list of meters used for solar calculations
  # @param [MeterCollection] meter_collection the school whose solar data is being processed
  def process(pv_meter_map, meter_collection)
    #Print debug output. Unused unless @debug_date_range is set
    print_detailed_results(pv_meter_map, 'Before solar pv calculation:')

    #Create the solar PV generation data (or override existing data if needed)
    create_generation_data(pv_meter_map, false)

    #Create an export meter, with empty data, unless there is one already
    create_export_meter_if_missing(pv_meter_map)

    #Calculate exported solar data. Might be populating a completely synthetic
    #meter, or overriding date ranges in real metered solar data
    create_or_override_export_data(pv_meter_map, meter_collection)

    #Create a self consumption meter, with empty data, unless there is one already
    create_self_consumption_meter_if_missing(pv_meter_map)

    #Calculate self consumption data. Might be populating a completely synthetic
    #meter, or overriding date ranges in real metered solar data
    create_self_consumption_data(pv_meter_map, meter_collection)

    #Print debug output. Unused unless @debug_date_range is set
    print_detailed_results(pv_meter_map, 'After solar pv calculation')
  end

  # Calculate solar PV generation for a given day
  #
  # @param [Date] date the day to calculate
  # @param [String] mpan the mpan for the meter
  def days_pv(date, mpan)
    capacity = degraded_kwp(date, :override_generation)
    pv_yield = @synthetic_sheffield_solar_pv_yields[date]
    scaled_pv_kwh_x48 = AMRData.one_day_zero_kwh_x48
    scaled_pv_kwh_x48 = AMRData.fast_multiply_x48_x_scalar(pv_yield, capacity / 2.0) unless capacity.nil? || pv_yield.nil?
    OneDayAMRReading.new(mpan, date, 'SOLR', nil, DateTime.now, scaled_pv_kwh_x48)
  end

  private

  #Creates a solar generation meter, if required, then populates the meter
  #with synthetic data
  #
  #For an existing meter, may just end up overridding specific days if
  #meter attributes are configured to do so
  #
  # @param [SolarMeterMap] pv_meter_map the solar meters
  # @param [boolean] create_zero_if_no_config THIS IS ALWAYS FALSE
  def create_generation_data(pv_meter_map, create_zero_if_no_config)
    pv_meter_map[:generation] = create_generation_meter_from_map(pv_meter_map) if pv_meter_map[:generation].nil?

    create_generation_amr_data(
      pv_meter_map[:mains_consume].amr_data,
      pv_meter_map[:generation].amr_data,
      pv_meter_map[:mains_consume].mpan_mprn,
      create_zero_if_no_config
      )
  end

  def create_export_meter_if_missing(pv_meter_map)
    pv_meter_map[:export] = create_export_meter_from_map(pv_meter_map) if pv_meter_map[:export].nil?
  end

  # Calculate or override the solar export data for the export meter in the SolarMeterMap
  def create_or_override_export_data(pv_meter_map, meter_collection)
    override_export_data_detail(
      pv_meter_map[:mains_consume].amr_data,
      pv_meter_map[:generation].amr_data,
      pv_meter_map[:export].amr_data,
      meter_collection,
      pv_meter_map[:mains_consume].mpan_mprn
      )
  end

  def create_self_consumption_meter_if_missing(pv_meter_map)
    pv_meter_map[:self_consume] = create_self_consumption_meter_from_map(pv_meter_map) if pv_meter_map[:self_consume].nil?
  end

  # Calculate or override the solar self consumption data for the self consumption meter in the SolarMeterMap
  def create_self_consumption_data(pv_meter_map, meter_collection)
    calculate_self_consumption_data(
      pv_meter_map[:mains_consume].amr_data,
      pv_meter_map[:generation].amr_data,
      pv_meter_map[:export].amr_data,
      pv_meter_map[:self_consume].amr_data,
      meter_collection,
      pv_meter_map[:mains_consume].mpan_mprn
      )
  end

  # @param [AmrData] mains_amr_data data for the mains consumption meter
  # @param [AmrData] pv_amr_data data for the pv generation meter
  # @param [String] mpan mpan/mprn for the mains consumption meter
  # @param [boolean] create_zero_if_no_config THIS IS ALWAYS FALSE?
  def create_generation_amr_data(mains_amr_data, pv_amr_data, mpan, create_zero_if_no_config)
    mains_amr_data.date_range.each do |date|
      # set only where config says so, either because we are overridding actual metered solar data
      # or we are just producing synthetic solar data
      if synthetic_data?(date, :override_generation)
        pv = days_pv(date, mpan)
        pv_amr_data.add(date, pv)
        compact_print_day('override generation', date, pv.kwh_data_x48)
      elsif create_zero_if_no_config
         # TODO: this never seems to be used, as param is always FALSE?
         #
         # pad out generation data to that of mains electric meter
         # so downstream analysis doesn't need to continually test
         # for its existence
        pv_amr_data.add(date, OneDayAMRReading.zero_reading(mpan, date, 'SOL0'))
        compact_print_day('override generation zero', date, negative_only_exported_kwh_x48)
      end
    end
  end

  # Calculate the solar export values based on the mains consumption and generation data
  #
  # @param [AmrData] main_amr the amr data for the mains consumption meter
  # @param [AmrData] pv_amr the amr data for the generation meter
  # @param [AmrData] export_amr the amr data for the export meter to be populated or updated
  # @param [MeterCollection] meter_collection the school
  # @param [String] mpan the mpan of the mains consumption meter
  def override_export_data_detail(mains_amr, pv_amr, export_amr, meter_collection, mpan)
    mains_amr.date_range.each do |date|
      if synthetic_data?(date, :override_export) # set only where config says so
        export_x48 = calculate_days_exported_days_data(date, meter_collection, mains_amr, pv_amr)
        export_amr.add(date, one_day_reading(mpan, date, 'SOLE', export_x48)) unless export_x48.nil?
      end
    end
  end

  # def maximum_export_kw(date)
  #   return 0.0 if real_production_data
  #   config = @solar_pv_panel_config.config_by_date_range.select { |date_range, config| date.between?(date_range.first, date_range.last) }
  #   return 0.0 if config.empty?
  #
  #   config.values.first[:maximum_export_level_kw] || 0.0
  # end

  # Calculate solar export for a single day
  #
  # Export calculation assumes that on days that a school is occupied there is
  # never enough generation to allow for export. Otherwise would need simulation
  # of schools consumption pattern in the absence of solar panels. This is known
  # limitation in our synthetic data generation.
  #
  # @param [Date] date the date to be calculated
  # @param [MeterCollection] meter_collection the school
  # @param [AmrData] mains_amr_data the AMR data for the mains meter
  # @param [AmrData] pv_amr_data the AMR data for the solar generation meter
  #
  # @return [Array] array of x48 half-hourly export values
  def calculate_days_exported_days_data(date, meter_collection, mains_amr_data, pv_amr_data)
    return nil unless synthetic_data?(date, :override_export)

    export_x48    = AMRData.one_day_zero_kwh_x48
    #return empty array if school is occupied
    return export_x48 unless unoccupied?(meter_collection, date)

    yesterday_baseload_kw   = yesterday_baseload_kw(date, mains_amr_data)

    (0..47).each do |hh_i|
      #how much are we consuming and generating?
      mains_kwh = mains_amr_data.kwh(date, hh_i)
      generation_kwh = pv_amr_data.kwh(date, hh_i)

      #assume we're always consuming at least the baseload
      unoccupied_appliance_kwh = [mains_kwh, yesterday_baseload_kw / 2.0].max

      #we are exporting if we're generating more than we're using
      if generation_kwh > unoccupied_appliance_kwh
        #how much are we exporting?
        #export will be a maximum of 0.0, as generation > usage
        export_kwh = [unoccupied_appliance_kwh - generation_kwh, 0.0].min
        export_x48[hh_i] = export_kwh
      end
    end

    compact_print_day('export', date, export_x48)

    export_x48
  end

  # Calculate the solar self consumption values based on the mains consumption, generation and export data
  #
  # @param [AmrData] main_amr the amr data for the mains consumption meter
  # @param [AmrData] pv_amr the amr data for the generation meter
  # @param [AmrData] export_amr the amr data for the export meter
  # @param [AmrData] self_consumption_amr the amr data for the self consumption meter that will be populated
  # @param [MeterCollection] meter_collection the school
  # @param [String] mpan the mpan of the mains consumption meter
  def calculate_self_consumption_data(mains_amr, pv_amr, export_amr, self_consumption_amr, meter_collection, mpan)
    mains_amr.date_range.each do |date|
      if synthetic_data?(date, :override_self_consume) # set only where config says so
        self_consume_x48 = calculate_days_self_consumption_days_data(date, meter_collection, mains_amr, pv_amr)
        unless self_consume_x48.nil?
          exported_x48 = export_amr.one_days_data_x48(date)
          generated_x48 = pv_amr.one_days_data_x48(date)
          self_consume_x48 = normalise_self_consumption(self_consume_x48, exported_x48, generated_x48)
          self_consumption_amr.add(date, one_day_reading(mpan, date, 'SOLO', self_consume_x48))
        end
      end
    end
  end

  # Calculate solar self consumption for a single day
  #
  # Calculation assumes that on days that a school is occupied all the generated
  # solar is consumed.
  #
  # @see SolarPVPanels.calculate_days_exported_days_data
  #
  # @param [Date] date the date to be calculated
  # @param [MeterCollection] meter_collection the school
  # @param [AmrData] mains_amr_data the AMR data for the mains meter
  # @param [AmrData] pv_amr_data the AMR data for the solar generation meter
  #
  # @return [Array] array of x48 half-hourly export values
  def calculate_days_self_consumption_days_data(date, meter_collection, mains_amr_data, pv_amr_data)
    return nil unless synthetic_data?(date, :override_self_consume)

    self_x48      = AMRData.one_day_zero_kwh_x48

    yesterday_baseload_kw = yesterday_baseload_kw(date, mains_amr_data)

    unoccupied = unoccupied?(meter_collection, date)
    (0..47).each do |hh_i|
      #how much are we consuming and generating?
      mains_kwh = mains_amr_data.kwh(date, hh_i)
      generation_kwh = pv_amr_data.kwh(date, hh_i)

      #assume we're always consuming at least the baseload
      unoccupied_appliance_kwh = [mains_kwh, yesterday_baseload_kw / 2.0].max

      if unoccupied
        #if school is unoccupied and we have some solar generation
        solar_pv_on           = generation_kwh > 0.0

        self_consumption_kwh  = solar_pv_on ? [unoccupied_appliance_kwh - mains_kwh, 0.0].max : 0.0
        self_x48[hh_i] = self_consumption_kwh
      else
        # else all the pv output is being consumed
        self_x48[hh_i] = generation_kwh
      end
    end

    compact_print_day('self consumption', date, self_x48)

    self_x48
  end

  #Post-processing step to normalise the calculated self-consumption. Will not
  #be required once we are able to do half-hourly offsets
  def normalise_self_consumption(self_consume_x48, exported_x48, generated_x48)
    return generated_x48 if exported_x48.all? { |hh| hh == 0.0 }

    #calculate total of (self consume - exported - generation)
    #we want this to be zero ideally, so if not, we will adjust the self consumption
    cross_check_total = self_consume_x48.map.with_index do |self_kwh, hh|
      self_kwh - exported_x48[hh] - generated_x48[hh]
    end.sum
    return self_consume_x48 if cross_check_total == 0.0

    #calculate how much to add to each hh period
    hh_periods_above_zero = self_consume_x48.count {|hh| hh > 0 }
    adjustment = cross_check_total / hh_periods_above_zero

    #adjust each period
    normalised_self_consume_x48 = self_consume_x48.map.with_index do |self_kwh, hh|
      #calculate revised self consumption using the adjustment value
      adjusted_kwh = self_kwh > 0 ? self_kwh - adjustment : 0.0
      #cannot be negative
      adjusted_kwh = 0.0 if adjusted_kwh < 0.0
      #adjusted value should not be lower than generation
      [adjusted_kwh, generated_x48[hh]].min
    end

    normalised_self_consume_x48
  end

  # Create a solar generation meter, based on the mains_consume meter in the map
  def create_generation_meter_from_map(pv_meter_map)
    date_range, meter_to_clone, meter_collection = meter_creation_data(pv_meter_map)
    create_generation_meter(date_range, meter_to_clone, meter_collection)
  end

  def create_generation_meter(date_range, meter_to_clone, meter_collection)
    create_meter(
      meter_to_clone,
      :solar_pv,
      :solar_pv,
      meter_collection,
      SolarPVPanels::SOLAR_PV_PRODUCTION_METER_NAME,
      'SOLR'
    )
  end

  # Create a solar export meter, based on the mains_consume meter in the map
  def create_export_meter_from_map(pv_meter_map)
    date_range, meter_to_clone, meter_collection = meter_creation_data(pv_meter_map)
    create_export_meter(date_range, meter_to_clone, meter_collection)
  end

  def create_export_meter(date_range, meter_to_clone, meter_collection)
    create_meter(
      meter_to_clone,
      :exported_solar_pv,
      :solar_pv_exported_sub_meter,
      meter_collection,
      SolarPVPanels::SOLAR_PV_EXPORTED_ELECTRIC_METER_NAME,
      'SOLE'
    )
  end

  # Create a solar self consumption meter, based on the mains_consume meter in the map
  def create_self_consumption_meter_from_map(pv_meter_map)
    date_range, meter_to_clone, meter_collection = meter_creation_data(pv_meter_map)
    create_self_consumption_meter(date_range, meter_to_clone, meter_collection)
  end

  def create_self_consumption_meter(date_range, meter_to_clone, meter_collection)
    create_meter(
      meter_to_clone,
      :solar_pv,
      :solar_pv_consumed_sub_meter,
      meter_collection,
      SolarPVPanels::SOLAR_PV_ONSITE_ELECTRIC_CONSUMPTION_METER_NAME,
      'SOLO'
    )
  end

  # Creates a new meter, cloning some values from an original
  #
  # Used to create a variety of different solar sub meters
  #
  # The values cloned include the floor area, number of pupils, solar and
  # storage heater configuration, plus some meter attributes
  #
  # The returned meter will have an empty AmrData object populated with empty
  # values for the same date range as the original meter
  #
  # @param [Dashboard::Meter] meter_to_clone the meter to copy from
  # @param [Symbol] meter_type the type of meter to create
  # @param [Symbol] pseudo_meter_type category of pseudo meter attributes
  # @param [MeterCollection] meter_collection the school to copy from
  # @param [String] meter_name name for the new meter
  # @param [String] reading_type a reading type used as default for the AMRData for this meter
  def create_meter(meter_to_clone, meter_type, pseudo_meter_type, meter_collection, meter_name, reading_type)
    date_range = meter_to_clone.amr_data.date_range
    amr_data = AMRData.create_empty_dataset(meter_type, date_range.first, date_range.last, reading_type)

    Dashboard::Meter.new(
      meter_collection: meter_to_clone.meter_collection,
      amr_data: amr_data,
      type: meter_type,
      identifier: Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(meter_collection.urn, meter_type),
      name: meter_name,
      floor_area: meter_to_clone.floor_area,
      number_of_pupils: meter_to_clone.number_of_pupils,
      solar_pv_installation: meter_to_clone.solar_pv_setup,
      meter_attributes: meter_to_clone.meter_attributes.merge(meter_to_clone.meter_collection.pseudo_meter_attributes(pseudo_meter_type))
    )
  end

  def meter_creation_data(pv_meter_map)
    [
      pv_meter_map[:mains_consume].amr_data.date_range,
      pv_meter_map[:mains_consume],
      pv_meter_map[:mains_consume].meter_collection
    ]
  end

  # Find the kwp value for a given date
  #
  # Will return nil if there were no panels installed on that date
  #
  # Otherwise returns the kwp value for the meters on that date, allowing for
  # panel degradation over time.
  def degraded_kwp(date, override_key)
    @solar_pv_panel_config.degraded_kwp(date, override_key)
  end

  def one_day_reading(mpan, date, type, data_x48 = Array.new(48, 0.0))
    OneDayAMRReading.new(mpan, date, type, nil, DateTime.now, data_x48)
  end

  #Is the school unoccupied on a given date
  def unoccupied?(meter_collection, date)
    DateTimeHelper.weekend?(date) || meter_collection.holidays.holiday?(date)
  end

  #Calculate baseload for previous day
  def yesterday_baseload_kw(date, electricity_amr)
    yesterday_date = date == electricity_amr.start_date ? electricity_amr.start_date : (date - 1)
    electricity_amr.overnight_baseload_kw(yesterday_date)
  end

  # Return true if we have solar panel configuration and we a kwp value for
  # the solar panels for the given day
  #
  # Used to decide whether to use synthetic data or not.
  def synthetic_data?(date, type)
    !@solar_pv_panel_config.nil? && !degraded_kwp(date, type).nil?
  end

  def debug_date?(date)
    return false if @debug_date_range.nil?

    date.between?(@debug_date_range.first, @debug_date_range.last)
  end

  def compact_print_day(type, date, kwh_x48)
    return unless debug_date?(date)

    puts "Calculated #{type} for #{date.strftime('%a %d %b %Y')} total = #{kwh_x48.sum.round(1)}"

    max_val = [kwh_x48.min.magnitude, kwh_x48.max.magnitude].max
    digits = max_val > 0.0 ? (Math.log10(max_val) + 2) : 2

    row_length = 48
    format = '%*.0f ' * row_length
    format_width = Array.new(row_length, digits.to_i)
    kwh_x48.each_slice(row_length) do |kwh_x8|
      puts format % format_width.zip(kwh_x8).flatten
    end
  end

  def print_detailed_results(pv_meter_map, when_message)
    return if @debug_date_range.nil?

    puts '-' * 60
    puts when_message

    @debug_date_range.each do |date|
      pv_meter_map.each do |type, meter|
        next if meter.nil?

        compact_print_day(type, date, meter.amr_data.days_kwh_x48(date))
      end
    end

    puts '-' * 60
  end
end

# Subclass used where we have metered generation data, but no export or
# self-consumption. Just ensures that the generation data is padded out
# to match the mains meter and treats entire date range as needing
# synthetic data
#
# called where metered generation meter but no export or self consumption
class SolarPVPanelsMeteredProduction < SolarPVPanels
  def initialize
    super(nil, nil)
    @real_production_data = true
  end

  private

  def create_generation_amr_data(mains_amr_data, pv_amr_data, mpan, create_zero_if_no_config)
    mains_amr_data.date_range.each do |date|
      unless pv_amr_data.date_exists?(date)
         # pad out generation data to that of mains electric meter
         # so downstream analysis doesn't need to continually test
         # for its existence
        pv_amr_data.add(date, OneDayAMRReading.zero_reading(mpan, date, 'SOL0'))
      end
    end
  end

  def synthetic_data?(_date, type)
    true
  end
end
