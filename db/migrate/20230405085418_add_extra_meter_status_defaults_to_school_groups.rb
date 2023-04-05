class AddExtraMeterStatusDefaultsToSchoolGroups < ActiveRecord::Migration[6.0]
  def change
    rename_column :school_groups, :admin_meter_statuses_id, :admin_meter_statuses_electricity_id
    add_column :school_groups, :admin_meter_statuses_gas_id, :bigint
    add_column :school_groups, :admin_meter_statuses_solar_pv_id, :bigint
  end
end
