class RemoveUserTariffsTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :user_tariff_prices
    drop_table :user_tariff_charges
    drop_table :user_tariffs
  end
end
