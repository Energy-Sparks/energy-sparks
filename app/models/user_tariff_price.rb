class UserTariffPrice < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_prices

  validates :start_time, :end_time, :value, :units, presence: true
end
