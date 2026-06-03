class UpdateElectricityTargetsToVersion2 < ActiveRecord::Migration[7.1]
  def change
    update_view :electricity_targets, version: 2, revert_to_version: 1
  end
end
