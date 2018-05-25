class DataFeedsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!

  def index
    @data_feeds = DataFeed.all
  end

  def show
    feed_id     = params[:id]
    feed_type   = params[:feed_type]
    start_date  = params[:start_date] || Date.yesterday - 1
    end_date    = params[:end_date] || Date.yesterday

    feed = DataFeed.find(feed_id)
    data = feed.to_csv(feed_type, start_date, end_date)
    respond_to do |format|
      format.csv { send_data data, filename: "data-feed-#{feed_type}-#{start_date}-#{end_date}.csv" }
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
