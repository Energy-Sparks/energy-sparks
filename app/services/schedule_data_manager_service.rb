class ScheduleDataManagerService
  include Logging

  # rubocop:disable Style/ClassVars
  @@holiday_data = {} # all indexed by area
  @@temperature_data = {}
  @@solar_irradiance_data = {}
  @@solar_pv_data = {}
  @@uk_grid_carbon_intensity_data = nil
  # rubocop:enable Style/ClassVars

  def self.holidays(calendar_id)
    return @@temperature_data[calendar_id] if @@temperature_data.key?(calendar_id)

    hol_data = HolidayData.new

    Calendar.find(calendar_id).holidays.order(:start_date).map do |holiday|
      hol_data << SchoolDatePeriod.new(:holiday, holiday.title, holiday.start_date, holiday.end_date)
    end

    hols = Holidays.new(hol_data)
    @@holiday_data[calendar_id] = hols
    @@holiday_data[calendar_id]
  end

  def self.process_feed_data(output_data, data_feed_type, area_id, feed_type)
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
  end

  def self.temperatures(temperature_area_id)
    return @@temperature_data[temperature_area_id] if @@temperature_data.key?(temperature_area_id) # lazy load data if not already loaded
    pp "TEMPS"
    temp_data = Temperatures.new('temperatures')
    process_feed_data(temp_data, "DataFeeds::WeatherUnderground", temperature_area_id, :temperature)

    # temp_data is an object of type Temperatures
    @@temperature_data[temperature_area_id] = temp_data
    @@temperature_data[temperature_area_id]
  end

  def self.solar_irradiation(solar_irradiance_area_id)
    return @@solar_irradiance_data[solar_irradiance_area_id] if @@solar_irradiance_data.key?(solar_irradiance_area_id) # lazy load data if not already loaded
    pp "SolarIrradiance"
    solar_data = SolarIrradiance.new('solar irradiance')
    process_feed_data(solar_data, "DataFeeds::WeatherUnderground", solar_irradiance_area_id, :solar_irradiation)

    @@solar_irradiance_data[solar_irradiance_area_id] = solar_data
    @@solar_irradiance_data[solar_irradiance_area_id]
  end

  def self.solar_pv(solar_pv_tuos_area_id)
    return @@solar_pv_data[solar_pv_tuos_area_id] if @@solar_pv_data.key?(solar_pv_tuos_area_id) # lazy load data if not already loaded
    pp "SolarPvTuos"
    solar_data = SolarPV.new('solar pv')
    process_feed_data(solar_data, "DataFeeds::SolarPvTuos", solar_pv_tuos_area_id, :solar_pv)

    @@solar_pv_data[solar_pv_tuos_area_id] = solar_data
    @@solar_pv_data[solar_pv_tuos_area_id]
  end

  # def self.uk_grid_carbon_intensity
  #   if @@uk_grid_carbon_intensity_data.nil?
  #     filename = INPUT_DATA_DIR + 'uk_carbon_intensity.csv'
  #     @@uk_grid_carbon_intensity_data = GridCarbonIntensity.new
  #     GridCarbonLoader.new(filename, @@uk_grid_carbon_intensity_data)
  #     puts "Loaded #{@@uk_grid_carbon_intensity_data.length} days of uk grid carbon intensity data"
  #   end
  #   @@uk_grid_carbon_intensity_data
  # end
end
