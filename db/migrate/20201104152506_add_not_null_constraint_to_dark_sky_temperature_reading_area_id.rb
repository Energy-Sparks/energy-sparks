class AddNotNullConstraintToDarkSkyTemperatureReadingAreaId < ActiveRecord::Migration[6.0]
  def change
    change_column_null :dark_sky_temperature_readings, :area_id, false
  end
end
