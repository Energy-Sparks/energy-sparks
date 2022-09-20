class AddFilterColumnRowsToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :column_row_filters, :jsonb, default: {}
  end
end
