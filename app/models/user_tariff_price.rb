class UserTariffPrice < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_prices
end
