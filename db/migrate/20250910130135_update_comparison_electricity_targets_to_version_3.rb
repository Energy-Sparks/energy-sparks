class UpdateComparisonElectricityTargetsToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_electricity_targets, version: 3, revert_to_version: 2, materialized: true
    add_index(:comparison_electricity_targets, :school_id, unique: true)
  end
end
