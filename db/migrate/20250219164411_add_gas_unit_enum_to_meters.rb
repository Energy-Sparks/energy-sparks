class AddGasUnitEnumToMeters < ActiveRecord::Migration[7.2]
  def change
    create_enum :gas_unit, %w[kwh m3 ft3 hcf]
    add_column :meters, :gas_unit, :enum, enum_type: :gas_unit
    add_column :amr_data_feed_configs, :check_meter_units, :boolean, default: false, null: false
  end
end
