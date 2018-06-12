class AddMoreMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :data_feed_readings, :feed_type
  end
end
