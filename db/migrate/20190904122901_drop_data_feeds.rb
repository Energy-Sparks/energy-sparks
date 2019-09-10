class DropDataFeeds < ActiveRecord::Migration[6.0]
  def change
    remove_column :areas, :data_feed_id, :integer
    drop_table  :data_feed_readings
    drop_table  :data_feeds
  end
end
