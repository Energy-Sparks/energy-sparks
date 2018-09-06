class DataFeedsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!

  def index
    @data_feeds = DataFeed.all
  end

  def show
    feed_id     = params[:id]
    feed_type   = params[:feed_type]
    start_date = if params[:start_date]
                   Date.parse(params[:start_date])
                 else
                   Date.yesterday - 1
                 end

    end_date = if params[:end_date]
                 Date.parse(params[:end_date])
               else
                 Date.yesterday
               end

    feed = DataFeed.find(feed_id)
    @readings = feed.readings(feed_type, start_date, end_date)

    respond_to do |format|
      format.csv do
        data_hash = @readings.pluck(:at, :value).to_h
        data = DataFeeds::WeatherUndergroundCsvWriter.new(nil, data_hash, :landscape).csv_as_array
        send_data data, filename: "data-feed-#{feed_type}-#{start_date}-#{end_date}.csv"
      end
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=data-feed-#{feed_type}-#{start_date}-#{end_date}.xlsx" }
    end
  end

  def destroy
    @data_feed = DataFeed.find(params[:id])
    @data_feed.delete
    respond_to do |format|
      format.html { redirect_to data_feeds_path, notice: 'Data feed was deleted.' }
      format.json { head :no_content }
    end
  end
end
