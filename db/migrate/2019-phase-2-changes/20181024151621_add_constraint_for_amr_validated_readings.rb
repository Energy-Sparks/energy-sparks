class AddConstraintForAmrValidatedReadings < ActiveRecord::Migration[5.2]
  def up
    execute(%Q{
    ALTER TABLE amr_validated_readings
    ADD CONSTRAINT unique_amr_meter_validated_readings UNIQUE(meter_id, reading_date);
    })
  end

  def down
    execute(%Q{
    ALTER TABLE amr_validated_readings
    DROP CONSTRAINT unique_amr_meter_validated_readings;
    })
  end
end