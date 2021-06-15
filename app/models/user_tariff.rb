class UserTariff < ApplicationRecord
  has_many :user_tariff_prices, inverse_of: :user_tariff
  has_many :user_tariff_charges, inverse_of: :user_tariff

  def electricity?
    fuel_type.to_sym == :electricity
  end

  def gas?
    fuel_type.to_sym == :gas
  end
end
