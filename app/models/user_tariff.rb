# == Schema Information
#
# Table name: user_tariffs
#
#  created_at :datetime         not null
#  end_date   :date             not null
#  flat_rate  :boolean          default(TRUE)
#  fuel_type  :text             not null
#  id         :bigint(8)        not null, primary key
#  name       :text             not null
#  school_id  :bigint(8)        not null
#  start_date :date             not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_tariffs_on_school_id  (school_id)
#
class UserTariff < ApplicationRecord
  belongs_to :school, inverse_of: :user_tariffs
  has_many :user_tariff_prices, inverse_of: :user_tariff
  has_many :user_tariff_charges, inverse_of: :user_tariff
  has_and_belongs_to_many :meters, inverse_of: :user_tariffs

  validates :name, :start_date, :end_date, presence: true

  scope :by_name, -> { order(name: :asc) }

  def electricity?
    fuel_type.to_sym == :electricity
  end

  def gas?
    fuel_type.to_sym == :gas
  end
end
