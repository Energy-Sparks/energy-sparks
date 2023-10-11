class AddIndexToOneDayKwh < ActiveRecord::Migration[6.0]
  def change
    # we use this in the admin meter report to find "zero days" for each meter
    add_index :amr_validated_readings, %i[meter_id one_day_kwh]
  end
end
