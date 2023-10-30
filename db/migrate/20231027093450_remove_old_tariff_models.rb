class RemoveOldTariffModels < ActiveRecord::Migration[6.0]
  def change
    #remove old join model between meters and user_tariffs
    drop_table :meters_user_tariffs
    drop_table :tariff_standing_charges
    drop_table :tariff_prices
  end
end
