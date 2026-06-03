class UpdateComparisonElectricityTargetsToVersion5 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_electricity_targets, version: 5, revert_to_version: 4, materialized: true
  end
end
