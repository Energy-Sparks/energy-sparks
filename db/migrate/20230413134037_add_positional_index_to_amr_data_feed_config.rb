class AddPositionalIndexToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :positional_index, :boolean, default: false, null: false
  end
end
