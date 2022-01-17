class AddFuelProgressToTarget < ActiveRecord::Migration[6.0]
  def change
    add_column :school_targets, :electricity_progress, :json, default: {}
    add_column :school_targets, :gas_progress, :json, default: {}
    add_column :school_targets, :storage_heaters_progress, :json, default: {}
  end
end
