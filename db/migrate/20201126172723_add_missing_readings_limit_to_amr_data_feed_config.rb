class AddMissingReadingsLimitToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :missing_readings_limit, :integer
  end
end
