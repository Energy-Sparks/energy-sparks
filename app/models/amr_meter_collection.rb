require 'dashboard'

# Meter collection is in the analytics code
class AmrMeterCollection < MeterCollection
  # This currently duplicates a lot of stuff in the analytics code initialiser, at some point wants separating out
  def initialize(active_record_school)
    set_up_meter_collection_attributes(active_record_school)
    set_up_meters(active_record_school)

    # From Dashboard meter collection
    # rubocop:disable Rails/TimeZone
    @cached_open_time = DateTime.new(0, 1, 1, 7, 0, 0) # for speed
    @cached_close_time = DateTime.new(0, 1, 1, 16, 30, 0) # for speed
    # rubocop:enable Rails/TimeZone

    @schedule_data_manager_service = ScheduleDataManagerService.new(active_record_school)

    # Pre-warm cache
    holidays
    temperatures

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

  # This isn't implemented yet properly, see school
  # TODO - should be @school.is_open?(time)
  def is_open?(time)
    school_day_in_hours(time)
  end

private

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

    # First run through
    AmrDataFeedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).each do |reading|
      reading_date = date_from_string_using_date_format(reading, hash_of_date_formats)
      amr_data.add(reading_date, OneDayAMRReading.new(active_record_meter.id, reading_date, 'ORIG', nil, reading.created_at, reading.readings.map(&:to_f)))
    end

    dashboard_meter.amr_data = amr_data
    dashboard_meter
  end

  def set_up_meters(active_record_school)
    @heat_meters = active_record_school.heat_meters.map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.id, active_record_meter.name)
      add_amr_data(dashboard_meter, active_record_meter)
    end

    @electricity_meters = active_record_school.electricity_meters.map do |active_record_meter|
      dashboard_meter = Dashboard::Meter.new(@school, nil, active_record_meter.meter_type.to_sym, active_record_meter.id, active_record_meter.name)
      add_amr_data(dashboard_meter, active_record_meter)
    end
  end

  def date_from_string_using_date_format(reading, hash_of_date_formats)
    date_format = hash_of_date_formats[reading.amr_data_feed_config_id]
    Date.strptime(reading.reading_date, date_format)
  end
end
