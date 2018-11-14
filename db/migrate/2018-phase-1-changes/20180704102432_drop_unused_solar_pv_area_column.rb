class DropUnusedSolarPvAreaColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools, :solar_pv_area_id if column_exists?(:schools, :solar_pv_area_id)
  end
end
