class AddConstraintForAmrReadings < ActiveRecord::Migration[5.2]
  def up
    execute(%Q{
    ALTER TABLE amr_readings
    ADD CONSTRAINT unique_amr_meter_readings UNIQUE(meter_id, one_day_kwh, status, date);
    })
  end

  def down
    execute(%Q{
    ALTER TABLE amr_readings
    DROP CONSTRAINT unique_amr_meter_readings;
    })
  end
end


#  date            :date             not null
#  id              :bigint(8)        not null, primary key
#  kwh_data_x48    :float            not null, is an Array
#  meter_id        :bigint(8)        not null
#  one_day_kwh     :float
#  substitute_date :date
#  type            :text             not null
#  upload_datetime :datetime
#