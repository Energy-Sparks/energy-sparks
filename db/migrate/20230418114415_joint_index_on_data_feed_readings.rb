class JointIndexOnDataFeedReadings < ActiveRecord::Migration[6.0]
  def change
    add_index :amr_data_feed_readings, [:meter_id, :amr_data_feed_config_id], name: 'adfr_meter_id_config_id'
  end
end
