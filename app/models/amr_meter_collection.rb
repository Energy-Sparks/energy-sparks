require 'dashboard'

# Meter collection is in the analytics code
class AmrMeterCollection < MeterCollection
  # This currently duplicates a lot of stuff in the analytics code initialiser, at some point wants separating out
  def initialize(active_record_school)
    set_up_meter_collection_attributes(active_record_school)
    set_up_meters(active_record_school)

    # From Dashboard meter collection
    @cached_open_time = TimeOfDay.new(7, 0) # for speed
    @cached_close_time = TimeOfDay.new(16, 30) # for speed

    @schedule_data_manager_service = ScheduleDataManagerService.new(active_record_school)

    # Pre-warm cache
    holidays
    temperatures

    @opening_times_hash = set_up_opening_time_hash(active_record_school).to_h

    pp "Running in Rails environment version: #{Dashboard::VERSION}"
  end

  def is_school_usually_open?(date, time_of_day)
    day_of_week_string = date.strftime("%A").downcase
    return false unless @opening_times_hash.key?(day_of_week_string)
    opening_time_of_day = @opening_times_hash[day_of_week_string][:opening_time]
    closing_time_of_day = @opening_times_hash[day_of_week_string][:closing_time]

    time_of_day >= opening_time_of_day && time_of_day < closing_time_of_day
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

  def is_open?(time)
    ActiveSupport::Deprecation.warn('is_open? is deprecated, please replace with is_school_usually_open?(date, time_of_day)')
    school_day_in_hours(time)
  end

private

  def set_up_opening_time_array(active_record_school)
    opening_times_array = active_record_school.school_times.pluck(:day, :opening_time, :closing_time)
    opening_times_array.map do |opening_time|
      [opening_time[0], {
        opening_time: convert_to_time_of_day(opening_time[1]),
        closing_time: convert_to_time_of_day(opening_time[2])
      }]
    end
  end

  def convert_to_time_of_day(hours_minutes_as_integer)
    minutes = hours_minutes_as_integer % 100
    hours = hours_minutes_as_integer.div 100
    TimeOfDay.new(hours, minutes)
  end

  def set_up_meter_collection_attributes(active_record_school)
    @name = active_record_school.name
    @address = active_record_school.address
    @postcode = active_record_school.postcode
    @floor_area = active_record_school.floor_area
    @number_of_pupils = active_record_school.number_of_pupils
    @urn = active_record_school.urn
    @area_name = active_record_school.area_name
    # Stored as big decimal
    @floor_area = active_record_school.floor_area.to_f

    @solar_pv_meters = []
    @storage_heater_meters = []
    @heating_models = {}

    @aggregated_heat_meters = nil
    @aggregated_electricity_meters = nil

    @meter_identifier_lookup = {} # [mpan or mprn] => meter

    @school = Dashboard::School.new(
      active_record_school.name,
      active_record_school.address,
      active_record_school.floor_area,
      active_record_school.number_of_pupils,
      active_record_school.school_type,
      active_record_school.area_name,
      active_record_school.urn,
      active_record_school.postcode
    )
  end

  def add_amr_data(dashboard_meter, active_record_meter)
    amr_data = AMRData.new(dashboard_meter.meter_type)

    hash_of_date_formats = AmrDataFeedConfig.pluck(:id, :date_format).to_h

    AmrDataFeedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).each do |reading|
      next if reading_invalid?(reading)
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      next if reading_date.nil?
      amr_data.add(reading_date, OneDayAMRReading.new(active_record_meter.id, reading_date, 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    dashboard_meter.amr_data = amr_data
    dashboard_meter
  end

  def reading_invalid?(reading)
    reading.readings.all?(&:blank?)
  end

  def set_up_meters(active_record_school)
    @heat_meters = active_record_school.meters_with_readings(:gas).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end

    @electricity_meters = active_record_school.meters_with_readings(:electricity).map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.mpan_mprn, active_record_meter.name, nil, nil, nil, nil, active_record_meter.id)
      add_amr_data(dashboard_meter, active_record_meter)
    end
  end

  def date_from_string_using_date_format(reading, hash_of_date_formats)
    date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
    begin
      Date.strptime(reading.reading_date, date_format)
    rescue ArgumentError
      nil
    end
  end
end
