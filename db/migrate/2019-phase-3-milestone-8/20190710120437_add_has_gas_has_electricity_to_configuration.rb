class AddHasGasHasElectricityToConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column(:configurations, :gas, :boolean, null: false, default: false)
    add_column(:configurations, :electricity, :boolean, null: false, default: false)
  end
end
