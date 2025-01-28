class AddMissingReadingWindowToAmrDataFeedConfig < ActiveRecord::Migration[7.1]
  def change
    add_column :amr_data_feed_configs, :missing_reading_window, :integer, default: 5
  end
end
