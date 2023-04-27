class AddDefaultProcurementRoutesToSchoolGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :default_procurement_route_electricity_id, :bigint
    add_column :school_groups, :default_procurement_route_gas_id, :bigint
    add_column :school_groups, :default_procurement_route_solar_pv_id, :bigint
  end
end
