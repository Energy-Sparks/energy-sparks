class AddUniqueConstraint < ActiveRecord::Migration[5.2]
  def up
    execute(%Q{
    ALTER TABLE amr_data_feed_readings
    ADD CONSTRAINT unique_meter_readings UNIQUE(mpan_mprn, reading_date);
    })
  end

  def down
    execute(%Q{
    ALTER TABLE amr_data_feed_readings
    DROP CONSTRAINT unique_meter_readings;
    })
  end
end
