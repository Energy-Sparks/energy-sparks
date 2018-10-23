# From analytics code - tweaked
require 'dashboard'

class AmrMeterCollection
  attr_reader :heat_meters, :electricity_meters, :solar_pv_meters, :storage_heater_meters

  # From school/building
  attr_reader :floor_area, :number_of_pupils

  # Currently, but not always
  attr_reader :school, :name, :address, :postcode, :urn, :area_name

  # These are things which will be populated
  attr_accessor :aggregated_heat_meters, :aggregated_electricity_meters, :heating_models, :electricity_simulation_meter

  def initialize(school)
    @name = school.name
    @address = school.address
    @postcode = school.postcode
    @floor_area = school.floor_area
    @number_of_pupils = school.number_of_pupils

    @heat_meters = []
    @electricity_meters = []
    @solar_pv_meters = []
    @storage_heater_meters = []
    @heating_models = {}
    @school = school
    @urn = school.urn
    @meter_identifier_lookup = {} # [mpan or mprn] => meter
    # Hard code for now
    @area_name = 'Bath'
    @aggregated_heat_meters = nil
    @aggregated_electricity_meters = nil

    @cached_open_time = DateTime.new(0, 1, 1, 7, 0, 0).utc # for speed
    @cached_close_time = DateTime.new(0, 1, 1, 16, 30, 0).utc # for speed

    @heat_meters = school.heat_meters
    @electricity_meters = school.electricity_meters
    # Stored as big decimal
    @floor_area = school.floor_area.to_f

    @heat_meters.each do |heat_meter|
      heat_meter.amr_data = add_amr_data(heat_meter)
    end

    @electricity_meters.each do |electricity_meter|
      electricity_meter.amr_data = add_amr_data(electricity_meter)
    end
    throw ArgumentException if school.meters.empty?
  end

  def add_amr_data(meter)
    amr_data = AMRData.new(meter.meter_type)

    # First run through
    AmrDataFeedReading.where(meter_id: meter.id).order(reading_date: :asc).each do |reading|
      amr_data.add(reading.reading_date, OneDayAMRReading.new(meter.id, reading.reading_date, 'ORIG', nil, reading.created_at, reading.readings))
   #  amr_data.add(reading.reading_date, AmrReading.new(meter_id: meter.id, date: reading.reading_date, type: 'ORIG', kwh_data_x48: reading.readings, upload_datetime: reading.created_at))
    end

    throw ArgumentException if school.meters.empty?

    amr_data
  end

  def matches_identifier?(identifier, identifier_type)
    case identifier_type
    when :name
      identifier == name
    when :urn
      identifier == urn
    when :postcode
      identifier == postcode
    else
      throw EnergySparksUnexpectedStateException.new("Unexpected nil school identifier_type") if identifier_type.nil?
      throw EnergySparksUnexpectedStateException.new("Unknown or implement school identifier lookup #{identifier_type}")
    end
  end

  def to_s
    'Meter Collection:' + name + ':' + all_meters.join(';')
  end

  def meter?(identifier)
    return @meter_identifier_lookup[identifier] if @meter_identifier_lookup.key?(identifier)

    all_meters.each do |meter|
      if meter.id == identifier
        @meter_identifier_lookup[identifier] = meter
        return meter
      end
    end
    @meter_identifier_lookup[identifier] = nil
  end

  def all_meters
    meter_groups = [
      @heat_meters,
      @electricity_meters,
      @solar_pv_meters,
      @storage_heater_meters,
      @aggregated_heat_meters,
      @aggregated_electricity_meters
    ]

    meter_list = []
    meter_groups.each do |meter_group|
      unless meter_group.nil?
        meter_list += (Object.const_defined?('Meter') && meter_group.is_a?(Meter)) || meter_group.is_a?(MeterAnalysis) ? [meter_group] : meter_group
      end
    end
    meter_list
  end

  def school_type
    @school.nil? ? nil : @school.school_type
  end

  def add_heat_meter(meter)
    meter.meter_type = meter.meter_type.to_sym if meter.meter_type.instance_of? String
    @heat_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_electricity_meter(meter)
    meter.meter_type = meter.meter_type.to_sym if meter.meter_type.instance_of? String
    @electricity_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_aggregate_heat_meter(meter)
    @aggregated_heat_meters = meter
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_aggregate_electricity_meter(meter)
    @aggregated_electricity_meters = meter
    @meter_identifier_lookup[meter.id] = meter
  end

  def is_open?(time)
    if @school.respond_to?('is_open?')
      @school.is_open?(time)
    else
      school_day_in_hours(time)
    end
  end

  # JAMES: TODO(JJ,3Jun2018): I gather you may have done something on this when working on holidays?
  def open_time
    @cached_open_time
  end

  def close_time
    @cached_close_time
  end

  def school_day_in_hours(time)
    # - use DateTime and not Time as orders of magnitude faster on Windows
    time_only = DateTime.new(0, 1, 1, time.hour, time.min, time.sec).utc
    time_only >= open_time && time_only < close_time
  end

  # held at building level as a school building e.g. a community swimming pool may have a different holiday schedule
  def holidays
    ScheduleDataManager.holidays(nil, @school.calendar_id)
  end

  def temperatures
    temperature_area_id = @school.temperature_area_id || DataFeed.find_by(type: "DataFeeds::WeatherUnderground").area_id
    ScheduleDataManager.temperatures(nil, temperature_area_id)
  end

  def solar_irradiation
    solar_irradiance_area_id = @school.solar_irradiance_area_id || DataFeed.find_by(type: "DataFeeds::WeatherUnderground").area_id
    ScheduleDataManager.solar_irradiation(nil, solar_irradiance_area_id)
  end

  def solar_pv
    solar_pv_tuos_area_id = @school.solar_pv_tuos_area_id || DataFeed.find_by(type: "DataFeeds::SolarPvTuos").area_id
    ScheduleDataManager.solar_pv(nil, solar_pv_tuos_area_id)
  end

  def grid_carbon_intensity
    ScheduleDataManager.uk_grid_carbon_intensity
  end

  def heating_model(period)
    unless @heating_models.key?(:basic)
      @heating_models[:basic] = AnalyseHeatingAndHotWater::BasicRegressionHeatingModel.new(@aggregated_heat_meters.amr_data, holidays, temperatures)
      @heating_models[:basic].calculate_regression_model(period)
    end
    @heating_models[:basic]
    #  @heating_on_periods = @model.calculate_heating_periods(@period)
  end
end
