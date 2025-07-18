class UpdateGasTargetsToVersion2 < ActiveRecord::Migration[7.1]
  def change
    update_view :gas_targets, version: 2, revert_to_version: 1
  end
end
