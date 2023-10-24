class AddDefaultDataSourcesToSchoolGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :default_data_source_electricity_id, :bigint
    add_column :school_groups, :default_data_source_gas_id, :bigint
    add_column :school_groups, :default_data_source_solar_pv_id, :bigint
  end
end
