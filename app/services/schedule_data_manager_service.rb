require 'dashboard'

class ScheduleDataManagerService
  def initialize(school)
    @calendar_id = school.calendar_id
    @solar_pv_tuos_area_id = school.solar_pv_tuos_area_id
    @dark_sky_area_id = school.dark_sky_area_id
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
    cache_key = "#{@dark_sky_area_id}-dark-sky-temperatures"
    @temperatures ||= Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = Temperatures.new('temperatures')

      DataFeeds::DarkSkyTemperatureReading.where(area_id: @dark_sky_area_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
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
end
