class AddUniquenessToDataFeedReadings < ActiveRecord::Migration[6.0]
  def up
    execute(%Q{
    ALTER TABLE data_feed_readings
    ADD CONSTRAINT unique_data_feed_readings UNIQUE(data_feed_id, feed_type, at);
    })
  end

  def down
    execute(%Q{
    ALTER TABLE data_feed_readings
    DROP CONSTRAINT unique_data_feed_readings;
    })
  end
end
