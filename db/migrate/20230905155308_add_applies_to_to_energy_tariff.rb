class AddAppliesToToEnergyTariff < ActiveRecord::Migration[6.0]
  def change
    add_column :energy_tariffs, :applies_to, :integer, default: 0 # enum defaults to :both
  end
end
