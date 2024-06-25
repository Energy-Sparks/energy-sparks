class AddDelayedReadingToAmrDataFeedConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :amr_data_feed_configs, :delayed_reading, :boolean, default: false, null: false
  end
end
