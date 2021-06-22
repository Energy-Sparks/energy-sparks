class AddIndexToAmrDataFeedReadings < ActiveRecord::Migration[6.0]
  def change
    add_index(:amr_data_feed_readings, :amr_data_feed_import_log_id)
  end
end
