class NightStorageHeaterOnboardingQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :indicated_has_storage_heaters, :boolean, default: false
    rename_column :schools, :has_solar_panels, :indicated_has_solar_panels
  end
end
