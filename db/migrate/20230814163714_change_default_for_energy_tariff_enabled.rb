class ChangeDefaultForEnergyTariffEnabled < ActiveRecord::Migration[6.0]
  def change
    change_column_default :energy_tariffs, :enabled, true
  end
end
