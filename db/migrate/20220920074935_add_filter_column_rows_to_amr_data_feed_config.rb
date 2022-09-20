class AddFilterColumnRowsToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :filter_column_rows, :jsonb, default: {}
  end
end
