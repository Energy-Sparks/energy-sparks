class AddTypeToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :process_type, :integer, default: 0, null: false
  end
end
