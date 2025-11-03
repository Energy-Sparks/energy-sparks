class TuneInactiveMeterReport < ActiveRecord::Migration[7.2]
  def change
    add_index :amr_data_feed_readings, [:created_at, :meter_id]
  end
end
