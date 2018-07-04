class ReportsController < AdminController
  def index
  end

  def amr_data_index
    @meters = Meter.where(active: true).includes(:school).order('schools.name')
  end

  def amr_data_show
    @meter = Meter.includes(:meter_readings).find(params[:meter_id])
    @first_reading = @meter.first_reading
    @reading_summary = @meter.meter_readings.order(Arel.sql('read_at::date')).group('read_at::date').count
    @missing_array = (@first_reading.read_at.to_date..Time.zone.today).collect do |day|
      if ! @reading_summary.key?(day)
        [day, 'No readings']
      elsif @reading_summary.key?(day) && @reading_summary[day] < 48
        [day, 'Partial readings']
      end
    end
    @missing_array.reject!(&:blank?)
  end

  def aggregated_amr_data_show
    @meter = Meter.includes(:aggregated_meter_readings).find(params[:meter_id])
    @first_reading = @meter.first_reading
    @reading_summary = @meter.aggregated_meter_readings.order(:when).pluck(:when, :readings).map {|day| { day[0] => day[1].count }}
    @reading_summary = @reading_summary.inject(:merge!)
    @missing_array = (@first_reading.read_at.to_date..Time.zone.today).collect do |day|
      if ! @reading_summary.key?(day)
        [day, 'No readings']
      elsif @reading_summary.key?(day) && @reading_summary[day] < 48
        [day, 'Partial readings']
      end
    end
    @missing_array.reject!(&:blank?)
  end

  # def data_feed_index
  #   @weather_underground = DataFeeds::WeatherUnderground.includes(:data_feed_readings).first
  #   @solar_pv = DataFeeds::SolarPvTuos.includes(:data_feed_readings).first

  #   @temperature_first_read = @weather_underground.first_reading(:temperature)
  #   @solar_irradiation_first_read = @weather_underground.first_reading(:solar_irradiation)
  #   @solar_pv_first_read = @solar_pv.first_reading(:solar_pv)

  #   @temperature_reading_summary = get_data_feed_readings(@weather_underground, :temperature)
  #   @solar_irradiation_reading_summary = get_data_feed_readings(@weather_underground, :solar_irradiation)
  #   @solar_pv_reading_summary = get_data_feed_readings(@solar_pv, :solar_pv)

  #   @temp_missing = get_missing_array(@temperature_first_read, @temperature_reading_summary)
  #   @solar_irradiation_missing = get_missing_array(@solar_irradiation_first_read, @solar_irradiation_reading_summary)
  #   @solar_pv_missing = get_missing_array(@solar_pv_first_read, @solar_pv_reading_summary)
  # end

  def data_feed_show
    feed_id = params[:id]
    @feed_type = params[:feed_type].to_sym

    @data_feed = DataFeed.find(feed_id)
    @first_read = @data_feed.first_reading(@feed_type)
    @reading_summary = get_data_feed_readings(@data_feed, @feed_type)
    @missing_array = get_missing_array(@first_read, @reading_summary)
  end

  def loading
    @schools = School.enrolled.order(:name)
  end

  def get_data_feed_readings(data_feed, feed_type)
    data_feed.data_feed_readings.where(feed_type: feed_type).order(Arel.sql('at::date')).group('at::date').count
  end

  def get_missing_array(first_reading, reading_summary)
    missing_array = (first_reading.at.to_date..Time.zone.today).collect do |day|
      if ! reading_summary.key?(day)
        [day, 'No readings']
      elsif reading_summary.key?(day) && reading_summary[day] < 48
        [day, 'Partial readings']
      elsif reading_summary.key?(day) && reading_summary[day] > 48
        [day, 'Too many readings!']
      end
    end
    missing_array.reject!(&:blank?)
  end
end
