class DataFeedsController < AdminController
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
end
