class AddReadingTimeToAmrDataFeedReading < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_readings, :reading_time, :text
  end
end
