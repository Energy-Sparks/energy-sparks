class AddGasUnitEnumToMeters < ActiveRecord::Migration[7.2]
  def change
    create_enum :gas_unit, %w[kwh cbm cbft hcf]
    add_column :meters, :gas_unit, :enum, enum_type: :gas_unit
  end
end
