class AddAllowMergingToDataFeedConfig < ActiveRecord::Migration[7.1]
  def change
    add_column :amr_data_feed_configs, :allow_merging, :boolean, default: false, null: false
  end
end
