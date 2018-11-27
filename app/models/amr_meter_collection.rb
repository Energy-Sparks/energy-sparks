# From analytics code - tweaked
require 'dashboard'

# Meter collection is in the analytics code
class AmrMeterCollection < MeterCollection
  # This currently duplicates a lot of stuff in the analytics code initialiser, at some point wants separating out
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
    @area_name = school.area_name
    @aggregated_heat_meters = nil
    @aggregated_electricity_meters = nil

    # rubocop:disable Rails/TimeZone
    @cached_open_time = DateTime.new(0, 1, 1, 7, 0, 0) # for speed
    @cached_close_time = DateTime.new(0, 1, 1, 16, 30, 0) # for speed
    # rubocop:enable Rails/TimeZone

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

    @schedule_data_manager_service = ScheduleDataManagerService.new(@school)

    throw ArgumentException if school.meters.empty?

    pp "Running in Rails environment version: #{Dashboard::VERSION}"
  end

  def holidays
    @schedule_data_manager_service.holidays
  end

  def temperatures
    @schedule_data_manager_service.temperatures
  end

  def solar_irradiation
    @schedule_data_manager_service.solar_irradiation
  end

  def solar_pv
    @schedule_data_manager_service.solar_pv
  end

  def add_amr_data(meter)
    amr_data = AMRData.new(meter.meter_type)

    hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

    # First run through
    AmrDataFeedReading.where(meter_id: meter.id).order(reading_date: :asc).each do |reading|
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      amr_data.add(reading_date, OneDayAMRReading.new(meter.id, reading_date, 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    throw ArgumentException if school.meters.empty?
    amr_data
  end

  # This isn't implemented yet properly, see school
  # TODO - should be @school.is_open?(time)
  def is_open?(time)
    school_day_in_hours(time)
  end

  def add_heat_meter(meter)
    # Set this to be a symbol for the analytics code
    meter.meter_type = meter.meter_type.to_sym

    @heat_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def add_electricity_meter(meter)
    # Set this to be a symbol for the analytics code
    meter.meter_type = meter.meter_type.to_sym

    @electricity_meters.push(meter)
    @meter_identifier_lookup[meter.id] = meter
  end

  def date_from_string_using_date_format(reading, hash_of_date_formats)
    date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
    Date.strptime(reading.reading_date, date_format)
  end
end
