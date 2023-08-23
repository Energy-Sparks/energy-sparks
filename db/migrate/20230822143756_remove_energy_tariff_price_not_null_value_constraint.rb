class RemoveEnergyTariffPriceNotNullValueConstraint < ActiveRecord::Migration[6.0]
  def change
    change_column_null :energy_tariff_prices, :value, true
    change_column_default :energy_tariff_prices, :value, from: 0.0, to: nil
  end
end
