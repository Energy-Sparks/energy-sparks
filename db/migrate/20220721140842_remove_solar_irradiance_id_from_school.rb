class RemoveSolarIrradianceIdFromSchool < ActiveRecord::Migration[6.0]
  def change
    remove_column :schools, :solar_irradiance_area_id, :bigint
  end
end
