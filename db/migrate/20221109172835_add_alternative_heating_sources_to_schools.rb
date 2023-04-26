class AddAlternativeHeatingSourcesToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :alternative_heating_oil, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_oil_percent, :integer, default: 0
    add_column :schools, :alternative_heating_oil_notes, :text

    add_column :schools, :alternative_heating_lpg, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_lpg_percent, :integer, default: 0
    add_column :schools, :alternative_heating_lpg_notes, :text

    add_column :schools, :alternative_heating_biomass, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_biomass_percent, :integer, default: 0
    add_column :schools, :alternative_heating_biomass_notes, :text

    add_column :schools, :alternative_heating_district_heating, :boolean, default: false, null: false
    add_column :schools, :alternative_heating_district_heating_percent, :integer, default: 0
    add_column :schools, :alternative_heating_district_heating_notes, :text
  end
end
