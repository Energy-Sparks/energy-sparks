class AddDateFunctionIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :data_feed_readings, "date_trunc('day', at)", name: 'data_feed_readings_at_index'
  end
end
