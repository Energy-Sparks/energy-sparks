class AddIndexToAmrDataFeedReadingsMeterIdAndCreatedAt < ActiveRecord::Migration[7.2]
  def change
    add_index :amr_data_feed_readings, %i[meter_id created_at]
  end
end
