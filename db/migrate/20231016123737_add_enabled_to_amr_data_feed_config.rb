class AddEnabledToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :enabled, :boolean, default: true, null: false
  end
end
