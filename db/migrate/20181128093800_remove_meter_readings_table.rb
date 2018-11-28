class RemoveMeterReadingsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :meter_readings
    drop_table :aggregated_meter_readings
  end
end
