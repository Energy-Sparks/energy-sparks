class AddDarkSkyForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :dark_sky_temperature_readings, :areas, on_delete: :cascade
    reversible do |dir|
      dir.up do
        connection.execute("DELETE FROM dark_sky_temperature_readings WHERE area_id IS NULL")
      end
    end
  end
end
