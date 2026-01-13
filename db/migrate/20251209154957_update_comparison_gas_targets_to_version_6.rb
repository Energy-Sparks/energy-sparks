class UpdateComparisonGasTargetsToVersion6 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_gas_targets,
      version: 6,
      revert_to_version: 5,
      materialized: true
  end
end
