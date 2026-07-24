class UpdateComparisonElectricityTargetsToVersion6 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_electricity_targets,
      version: 6,
      revert_to_version: 5,
      materialized: true
  end
end
