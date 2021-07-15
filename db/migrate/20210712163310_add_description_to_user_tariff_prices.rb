class AddDescriptionToUserTariffPrices < ActiveRecord::Migration[6.0]
  def change
    add_column :user_tariff_prices, :description, :string
  end
end
