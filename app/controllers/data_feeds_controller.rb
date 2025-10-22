class DataFeedsController < ApplicationController
  load_and_authorize_resource

  CSV_HEADER = 'Reading Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

  def show
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
        send_data CsvDownloader.readings_to_csv(sql_query, CSV_HEADER), filename: "data-feed-readings-#{@data_feed.title.parameterize}-#{@feed_type.to_s.parameterize}.csv"
      end
      format.json
    end
  end

private

  def get_data_feed_readings(data_feed, feed_type)
    data_feed.data_feed_readings.where(feed_type: feed_type).order(Arel.sql('at::date')).group('at::date').count
  end

  def sql_query_for_downloading(data_feed_id, feed_type)
    DataFeedReading.download_query(data_feed_id, feed_type)
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
