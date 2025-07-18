class RemoveDefaultTuosAreas < ActiveRecord::Migration[7.2]
  def change
    remove_column :school_onboardings, :solar_pv_tuos_area_id, :bigint
    remove_column :school_groups, :default_solar_pv_tuos_area_id, :bigint
  end
end
