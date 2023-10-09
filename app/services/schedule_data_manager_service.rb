require 'dashboard'

class ScheduleDataManagerService
  DEFAULT_TARGET_TEMPERATURE_DAYS_EITHER_SIDE = 4
  CACHE_EXPIRY = 4.hours

  def initialize(school, meter_data_type = :unvalidated_meter_data)
    @school = school
    @meter_data_type = meter_data_type
    raise 'Invalid meter data type' unless [:validated_meter_data, :unvalidated_meter_data].include?(meter_data_type)
    @calendar = school.calendar
    @solar_pv_tuos_area_id = school.solar_pv_tuos_area_id
    @dark_sky_area_id = school.dark_sky_area_id
    @weather_station_id = school.weather_station_id
  end

  def self.invalidate_cached_calendar(calendar)
    Rails.cache.delete(self.calendar_cache_key(calendar))
  end

  def self.calendar_cache_key(calendar)
    "#{calendar.id}-holidays"
  end

  def holidays
    @holidays ||= find_holidays
  end

  def temperatures
    @temperatures ||= find_temperatures
  end

  def solar_pv
    @solar_pv ||= find_solar_pv
  end

  def uk_grid_carbon_intensity
    @uk_grid_carbon_intensity ||= find_uk_grid_carbon_intensity
  end

  private

  def use_date_bounded_schedule_data?
    return false unless EnergySparks::FeatureFlags.active?(:date_bound_schedule_data)
    return false unless school_minimum_reading_date_present
    return false unless @meter_data_type == :validated_meter_data

    true
  end

  def school_minimum_reading_date_present
    @school_minimum_reading_date_present ||= @school.minimum_reading_date.present?
  end

  def find_solar_pv
    cache_key = "#{@solar_pv_tuos_area_id}-solar-pv-2-tuos"
    cached_solar_pv ||= Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      data = SolarPV.new('solar pv')
      DataFeeds::SolarPvTuosReading.where(area_id: @solar_pv_tuos_area_id).pluck(:reading_date, :generation_mw_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
      end
      data
    end

    # Only use solar pv data within lower datetime bounds of school meter readings
    return cached_solar_pv unless use_date_bounded_schedule_data?

    dates_to_remove = cached_solar_pv.keys.select { |date| date < @school.minimum_reading_date }
    cached_solar_pv.remove_dates!(*dates_to_remove)
  end

  def find_uk_grid_carbon_intensity
    cache_key = "co2-feed"
    cached_uk_grid_carbon_intensity ||= Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      uk_grid_carbon_intensity_data = GridCarbonIntensity.new
      DataFeeds::CarbonIntensityReading.all.pluck(:reading_date, :carbon_intensity_x48).each do |date, values|
        uk_grid_carbon_intensity_data.add(date, values.map(&:to_f))
      end
      uk_grid_carbon_intensity_data
    end

    # Only use uk grid carbon intensity data within lower datetime bounds of school meter readings
    return cached_uk_grid_carbon_intensity unless use_date_bounded_schedule_data?

    dates_to_remove = cached_uk_grid_carbon_intensity.keys.select { |date| date < @school.minimum_reading_date }
    cached_uk_grid_carbon_intensity.remove_dates!(*dates_to_remove)
  end

  def find_temperatures
    cache_key = cache_key_temperatures
    cached_temperatures ||= Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      data = Temperatures.new('temperatures')

      #FEATURE FLAG: if this is set then we want to start using Meteostat data
      #Relies on the school, or its group also having been associated with
      #a station
      if EnergySparks::FeatureFlags.active?(:use_meteostat)
        earliest = load_meteostat_readings(data)
        load_dark_sky_readings(data, earliest)
      else
        load_dark_sky_readings(data)
      end
      data
    end

    # Only use temperature data within lower datetime bounds of school meter readings
    return cached_temperatures unless use_date_bounded_schedule_data?

    school_minimum_reading_date = school_minimum_reading_date_with_temperature_days_offset
    dates_to_remove = cached_temperatures.keys.select { |date| date < school_minimum_reading_date }
    cached_temperatures.remove_dates!(*dates_to_remove)
  end

  def school_minimum_reading_date_with_temperature_days_offset
    @school.minimum_reading_date - 1.year - temperature_days_offset.days
  end

  def temperature_days_offset
    # The projected future temperature is calculated from an average of the past temperatures at the same time
    # of year in previous years, the number needs to be smooth and not too noisy, '4 days either side' provides
    # this averaging, otherwise you get a much more volatile temperature adjustment.
    if TargetMeterTemperatureCompensatedDailyDayTypeBase.const_defined?('TARGET_TEMPERATURE_DAYS_EITHER_SIDE')
       TargetMeterTemperatureCompensatedDailyDayTypeBase::TARGET_TEMPERATURE_DAYS_EITHER_SIDE
    else
       DEFAULT_TARGET_TEMPERATURE_DAYS_EITHER_SIDE
    end
  end

  def find_holidays
    Rails.cache.fetch(self.class.calendar_cache_key(@calendar), expires_in: CACHE_EXPIRY) do
      hol_data = HolidayData.new

      Calendar.find(@calendar.id).outside_term_time.order(:start_date).includes(:academic_year, :calendar_event_type).map do |holiday|
        academic_year = nil # Not really being used at the moment by the analytics code

        analytics_holiday = Holiday.new(
          holiday.calendar_event_type.analytics_event_type.to_sym,
          nil,
          holiday.start_date,
          holiday.end_date,
          academic_year
        )

        hol_data.add(analytics_holiday)
      end
      Holidays.new(hol_data)
    end
  end

  def cache_key_temperatures
    if EnergySparks::FeatureFlags.active?(:use_meteostat)
      "#{@weather_station_id}-#{@dark_sky_area_id}-dark-sky-temperatures"
    else
      "#{@dark_sky_area_id}-dark-sky-temperatures"
    end
  end

  #Load Meteostat readings if there are any
  #returns earliest date encountered
  def load_meteostat_readings(temperatures)
    earliest = nil
    WeatherObservation.where(weather_station_id: @weather_station_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
      if earliest.nil?
        earliest = date
      elsif date < earliest
        earliest = date
      end
      temperatures.add(date, values.map(&:to_f))
    end
    earliest
  end

  #Load Dark Sky readings if there's any associated with schools
  #Optionally only loading those from before a specified date
  def load_dark_sky_readings(temperatures, earliest = nil)
    if @dark_sky_area_id.present?
      if earliest.present?
        DataFeeds::DarkSkyTemperatureReading.where("area_id = ? AND reading_date < ?", @dark_sky_area_id, earliest).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
          temperatures.add(date, values.map(&:to_f))
        end
      else
        DataFeeds::DarkSkyTemperatureReading.where(area_id: @dark_sky_area_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
          temperatures.add(date, values.map(&:to_f))
        end
      end
    end
  end
end
