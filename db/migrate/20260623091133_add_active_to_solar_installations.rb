# frozen_string_literal: true

class AddActiveToSolarInstallations < ActiveRecord::Migration[8.1]
  def change
    add_column :solar_edge_installations, :active, :boolean, default: true, null: false
    add_column :low_carbon_hub_installations, :active, :boolean, default: true, null: false
    add_column :rtone_variant_installations, :active, :boolean, default: true, null: false
    add_column :solis_cloud_installations, :active, :boolean, default: true, null: false
  end
end
