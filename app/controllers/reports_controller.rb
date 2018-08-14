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
    @missing_array = get_missing_array(@first_reading, @reading_summary)
  end

  def aggregated_amr_data_show
    @meter = Meter.includes(:aggregated_meter_readings).find(params[:meter_id])
    @first_reading = @meter.first_reading
    @reading_summary = @meter.aggregated_meter_readings.order(:when).pluck(:when, :readings).map {|day| { day[0] => day[1].count }}
    @reading_summary = @reading_summary.inject(:merge!)
    @missing_array = get_missing_array(@first_reading, @reading_summary)
  end

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

  def cache_report
    @cache_keys = Rails.cache.instance_variable_get(:@data).keys
    @cache_report = @cache_keys.map do |key|
      created_at = Rails.cache.send(:read_entry, key, {}).instance_variable_get('@created_at')
      expires_in = Rails.cache.send(:read_entry, key, {}).instance_variable_get('@expires_in')
      expiry_time = created_at + expires_in
      minutes_left = ((Time.at(expiry_time).utc - Time.now.utc) / 1.minute).round
      { key: key, created_at: Time.at(created_at).utc, expiry_time: Time.at(expiry_time).utc, minutes_left: minutes_left }
    end
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
