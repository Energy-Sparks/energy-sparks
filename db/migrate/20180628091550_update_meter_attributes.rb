class UpdateMeterAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :meters, :mpan_mprn, :bigint
    add_column :meters, :meter_serial_number, :text
    add_column :meters, :solar_pv,  :boolean, default: false
    add_column :meters, :storage_heaters, :boolean, default: false
    add_column :meters, :number_of_pupils, :integer
    add_column :meters, :floor_area, :decimal
  end
end
