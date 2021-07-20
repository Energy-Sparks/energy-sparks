require 'dashboard'

class ScheduleDataManagerService
  def initialize(school)
    @calendar_id = school.calendar_id
    @solar_pv_tuos_area_id = school.solar_pv_tuos_area_id
    @dark_sky_area_id = school.dark_sky_area_id
    @weather_station_id = school.weather_station_id
  end

  def holidays
    cache_key = "#{@calendar_id}-holidays"
    @holidays ||= Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      hol_data = HolidayData.new

      Calendar.find(@calendar_id).outside_term_time.order(:start_date).includes(:academic_year).map do |holiday|
        academic_year = nil # Not really being used at the moment by the analytics code

        analytics_holiday = Holiday.new(
          holiday.calendar_event_type.analytics_event_type.to_sym,
          holiday.title || 'No title',
          holiday.start_date,
          holiday.end_date,
          academic_year
        )

        hol_data.add(analytics_holiday)
      end
      Holidays.new(hol_data)
    end
  end

  def temperatures
    cache_key = cache_key_temperatures
    @temperatures ||= Rails.cache.fetch(cache_key, expires_in: 3.hours) do
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
  end

  def solar_pv
    cache_key = "#{@solar_pv_tuos_area_id}-solar-pv-2-tuos"
    @solar_pv ||= Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = SolarPV.new('solar pv')
      DataFeeds::SolarPvTuosReading.where(area_id: @solar_pv_tuos_area_id).pluck(:reading_date, :generation_mw_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
      end
      data
    end
  end

  def uk_grid_carbon_intensity
    cache_key = "co2-feed"
    @uk_grid_carbon_intensity ||= Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      uk_grid_carbon_intensity_data = GridCarbonIntensity.new
      DataFeeds::CarbonIntensityReading.all.pluck(:reading_date, :carbon_intensity_x48).each do |date, values|
        uk_grid_carbon_intensity_data.add(date, values.map(&:to_f))
      end
      uk_grid_carbon_intensity_data
    end
  end

  private

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
