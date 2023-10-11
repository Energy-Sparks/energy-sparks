class UpdateMeterAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :meters, :mpan_mprn, :bigint, index: true
    add_column :meters, :meter_serial_number, :text, index: true
    add_column :meters, :solar_pv, :boolean, default: false, index: true
    add_column :meters, :storage_heaters, :boolean, default: false, index: true
    add_column :meters, :number_of_pupils, :integer
    add_column :meters, :floor_area, :decimal
  end
end
