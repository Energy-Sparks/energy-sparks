# From analytics code - tweaked
require 'dashboard'

class AmrMeterCollection < MeterCollection
  # This currently duplicates a lot of stuff in the initialiser, at some point wants separating out
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

    @cached_open_time = DateTime.new(0, 1, 1, 7, 0, 0).utc # for speed
    @cached_close_time = DateTime.new(0, 1, 1, 16, 30, 0).utc # for speed

    pp "Running in Rails environment version: #{Dashboard::VERSION}"
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

  # held at building level as a school building e.g. a community swimming pool may have a different holiday schedule
  def holidays
    ScheduleDataManagerService.holidays(@school.calendar_id)
  end

  def temperatures
    ScheduleDataManagerService.temperatures(@school.weather_underground_area_id)
  end

  def solar_irradiation
    ScheduleDataManagerService.solar_irradiation(@school.weather_underground_area_id)
  end

  def solar_pv
    ScheduleDataManagerService.solar_pv(@school.solar_pv_tuos_area_id)
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

  def date_from_string_using_date_format(reading, hash_of_date_formats)
    date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
    Date.strptime(reading.reading_date, date_format)
  end
end
