class UpdateComparisonGasTargetsToVersion4 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_gas_targets, version: 4, revert_to_version: 3, materialized: true
  end
end
