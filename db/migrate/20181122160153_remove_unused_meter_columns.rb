class RemoveUnusedMeterColumns < ActiveRecord::Migration[5.2]
  def up
    remove_column :meters, :number_of_pupils
    remove_column :meters, :solar_pv
    remove_column :meters, :storage_heaters
    remove_column :meters, :floor_area
  end
  def down
    add_column :meters, :number_of_pupils, :integer
    add_column :meters, :solar_pv, :boolean, default: false
    add_column :meters, :storage_heaters, :boolean, default: false
    add_column :meters, :floor_area, :decimal
  end
end
