class UserTariff < ApplicationRecord
  belongs_to :school, inverse_of: :user_tariffs
  has_many :user_tariff_prices, inverse_of: :user_tariff
  has_many :user_tariff_charges, inverse_of: :user_tariff

  validates :name, :start_date, :end_date, presence: true

  scope :by_name, -> { order(name: :asc) }

  def electricity?
    fuel_type.to_sym == :electricity
  end

  def gas?
    fuel_type.to_sym == :gas
  end
end
