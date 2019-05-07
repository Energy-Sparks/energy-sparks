require 'dashboard'

class ScheduleDataManagerService
  def initialize(school)
    @calendar_id = school.calendar_id
    @temperature_area_id = school.weather_underground_area_id
    @solar_irradiance_area_id = school.weather_underground_area_id
    @solar_pv_tuos_area_id = school.solar_pv_tuos_area_id
    @dark_sky_area_id = school.dark_sky_area_id
  end

  def holidays
    cache_key = "#{@calendar_id}-holidays"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      hol_data = HolidayData.new

      Calendar.find(@calendar_id).holidays.order(:start_date).map do |holiday|
        hol_data << SchoolDatePeriod.new(:holiday, holiday.title, holiday.start_date, holiday.end_date)
      end

      Holidays.new(hol_data)
    end
  end

  def process_feed_data(output_data, data_feed_type, area_id, feed_type)
    data_feed = DataFeed.find_by(type: data_feed_type, area_id: area_id)

    query = <<-SQL
      SELECT date_trunc('day', at) AS day, array_agg(value ORDER BY at ASC) AS values
      FROM data_feed_readings
      WHERE feed_type = #{DataFeedReading.feed_types[feed_type]}
      AND data_feed_id = #{data_feed.id}
      GROUP BY date_trunc('day', at)
      ORDER BY day ASC
    SQL

    result = ActiveRecord::Base.connection.execute(query)
    result.each do |row|
      output_data.add(Date.parse(row["day"]), row["values"].delete('{}').split(',').map(&:to_f))
    end
    output_data
  end

  def temperatures
    ENV['DARK_SKY_FOR_TEMPERATURES'] ? dark_sky_temperatures : weather_underground_temperatures
  end

  def solar_irradiation
    cache_key = "#{@solar_irradiance_area_id}-solar-irradiation"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = SolarIrradiance.new('solar irradiance')
      process_feed_data(data, "DataFeeds::WeatherUnderground", @solar_irradiance_area_id, :solar_irradiation)
    end
  end

  def solar_pv
    cache_key = "#{@solar_pv_tuos_area_id}-solar-pv-tuos"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = SolarPV.new('solar pv')
      process_feed_data(data, "DataFeeds::SolarPvTuos", @solar_pv_tuos_area_id, :solar_pv)
    end
  end

private

  def weather_underground_temperatures
    cache_key = "#{@temperature_area_id}-weather-underground-temperatures"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = Temperatures.new('temperatures')
      process_feed_data(data, "DataFeeds::WeatherUnderground", @temperature_area_id, :temperature)
    end
  end

  def dark_sky_temperatures
    cache_key = "#{@dark_sky_area_id}-dark-sky-temperatures"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      data = Temperatures.new('temperatures')

      DataFeeds::DarkSkyTemperatureReading.where(area_id: @dark_sky_area_id).pluck(:reading_date, :temperature_celsius_x48).each do |date, values|
        data.add(date, values.map(&:to_f))
      end
      data
    end
  end
end
