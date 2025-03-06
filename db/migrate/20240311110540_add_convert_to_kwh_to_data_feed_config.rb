class AddConvertToKwhToDataFeedConfig < ActiveRecord::Migration[6.1]
  def change
    add_column :amr_data_feed_configs, :convert_to_kwh, :boolean, default: false
  end
end
