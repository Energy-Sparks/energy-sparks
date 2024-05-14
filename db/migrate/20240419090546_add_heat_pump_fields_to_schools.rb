class AddHeatPumpFieldsToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :alternative_heating_ground_source_heat_pump, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_ground_source_heat_pump_percent, :integer, default: 0
    add_column :schools, :alternative_heating_ground_source_heat_pump_notes, :text

    add_column :schools, :alternative_heating_air_source_heat_pump, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_air_source_heat_pump_percent, :integer, default: 0
    add_column :schools, :alternative_heating_air_source_heat_pump_notes, :text
  end
end
