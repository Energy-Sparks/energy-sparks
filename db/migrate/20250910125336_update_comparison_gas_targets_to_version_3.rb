class UpdateComparisonGasTargetsToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_gas_targets, version: 3, revert_to_version: 2, materialized: true
    add_index(:comparison_gas_targets, :school_id, unique: true)
  end
end
