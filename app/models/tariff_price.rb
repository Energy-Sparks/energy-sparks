class TariffPrice < ApplicationRecord
  def tariff_prices
    JSON.parse(prices)
  end
end
