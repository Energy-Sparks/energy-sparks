class AddFkToAmrDataFeedReadings < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :amr_data_feed_readings, :meters, on_delete: :nullify
    add_foreign_key :amr_data_feed_readings, :amr_data_feed_configs, on_delete: :cascade
  end
end
