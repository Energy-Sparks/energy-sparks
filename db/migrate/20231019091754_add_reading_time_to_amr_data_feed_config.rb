class AddReadingTimeToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :reading_time_field, :text
  end
end
