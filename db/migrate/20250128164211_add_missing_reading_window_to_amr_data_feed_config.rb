class AddMissingReadingWindowToAmrDataFeedConfig < ActiveRecord::Migration[7.1]
  def change
    add_column :amr_data_feed_configs, :missing_reading_window, :integer
    change_column_default :amr_data_feed_configs, :missing_reading_window, from: nil, to: 5
  end
end
