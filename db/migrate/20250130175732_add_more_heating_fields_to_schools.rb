class AddMoreHeatingFieldsToSchools < ActiveRecord::Migration[7.1]
  def change
    change_table :schools, bulk: true do |t|
      t.boolean :heating_gas, default: false, null: false
      t.integer :heating_gas_percent, default: 0
      t.text :heating_gas_notes

      t.boolean :heating_electric, default: false, null: false
      t.integer :heating_electric_percent, default: 0
      t.text :heating_electric_notes

      t.boolean :heating_underfloor, default: false, null: false
      t.integer :heating_underfloor_percent, default: 0
      t.text :heating_underfloor_notes

      t.boolean :heating_chp, default: false, null: false
      t.integer :heating_chp_percent, default: 0
      t.text :heating_chp_notes

      t.rename :alternative_heating_air_source_heat_pump, :heating_air_source_heat_pump
      t.rename :alternative_heating_air_source_heat_pump_notes, :heating_air_source_heat_pump_notes
      t.rename :alternative_heating_air_source_heat_pump_percent, :heating_air_source_heat_pump_percent

      t.rename :alternative_heating_biomass, :heating_biomass
      t.rename :alternative_heating_biomass_notes, :heating_biomass_notes
      t.rename :alternative_heating_biomass_percent, :heating_biomass_percent

      t.rename :alternative_heating_district_heating, :heating_district_heating
      t.rename :alternative_heating_district_heating_notes, :heating_district_heating_notes
      t.rename :alternative_heating_district_heating_percent, :heating_district_heating_percent

      t.rename :alternative_heating_ground_source_heat_pump, :heating_ground_source_heat_pump
      t.rename :alternative_heating_ground_source_heat_pump_notes, :heating_ground_source_heat_pump_notes
      t.rename :alternative_heating_ground_source_heat_pump_percent, :heating_ground_source_heat_pump_percent

      t.rename :alternative_heating_lpg, :heating_lpg
      t.rename :alternative_heating_lpg_notes, :heating_lpg_notes
      t.rename :alternative_heating_lpg_percent, :heating_lpg_percent

      t.rename :alternative_heating_oil, :heating_oil
      t.rename :alternative_heating_oil_notes, :heating_oil_notes
      t.rename :alternative_heating_oil_percent, :heating_oil_percent

      t.rename :alternative_heating_water_source_heat_pump, :heating_water_source_heat_pump
      t.rename :alternative_heating_water_source_heat_pump_notes, :heating_water_source_heat_pump_notes
      t.rename :alternative_heating_water_source_heat_pump_percent, :heating_water_source_heat_pump_percent
    end
  end
end
