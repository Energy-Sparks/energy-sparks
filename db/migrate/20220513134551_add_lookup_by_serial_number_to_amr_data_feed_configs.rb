class AddLookupBySerialNumberToAmrDataFeedConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :lookup_by_serial_number, :boolean, default: false
  end
end
