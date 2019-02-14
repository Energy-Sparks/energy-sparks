require 'dashboard'

class ReportsController < AdminController
  include CsvDownloader

  COLOUR_ARRAY = ['#5cb85c', "#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749", "#e5644e", "#cd4851", "#bd4d65", "#515749"].freeze
  CSV_HEADER = "Reading Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00".freeze

  def index
  end

  def amr_data_index
    @meters = Meter.where(active: true).includes(:school).order('schools.name')
  end

  def amr_readings_show
    @amr_types = OneDayAMRReading::AMR_TYPES
    @colour_hash = COLOUR_ARRAY.each_with_index.map { |colour, index| [@amr_types.keys[index], colour] }.to_h
    @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])

    @first_validated_reading_date = @meter.first_validated_reading
    respond_to do |format|
      format.json do
        @reading_summary = @meter.amr_validated_readings.order(:reading_date).pluck(:reading_date, :status).map {|day| { day[0] => day[1] }}
        @reading_summary = @reading_summary.inject(:merge!)
      end
      format.html
    end
  end

  def data_feed_show
    feed_id = params[:id]
    @feed_type = params[:feed_type].to_sym

    @data_feed = DataFeed.find(feed_id)
    @first_read = @data_feed.first_reading(@feed_type)
    @reading_summary = get_data_feed_readings(@data_feed, @feed_type)
    @missing_array = get_missing_array(@first_read, @reading_summary)
    respond_to do |format|
      format.html
      format.csv do
        sql_query = sql_query_for_downloading(@data_feed.id, @feed_type)
        send_data readings_to_csv(sql_query, CSV_HEADER), filename: "data-feed-readings-#{@data_feed.title.parameterize}-#{@feed_type.to_s.parameterize}.csv"
      end
      format.json
    end
  end

  def loading
    @schools = School.active.order(:name)
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

private

  def sql_query_for_downloading(data_feed_id, feed_type)
    DataFeedReading.download_query(data_feed_id, feed_type)
  end
end
