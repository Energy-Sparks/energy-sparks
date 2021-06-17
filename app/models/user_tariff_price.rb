# == Schema Information
#
# Table name: user_tariff_prices
#
#  created_at     :datetime         not null
#  end_time       :text             not null
#  id             :bigint(8)        not null, primary key
#  start_time     :text             not null
#  units          :text             not null
#  updated_at     :datetime         not null
#  user_tariff_id :bigint(8)        not null
#  value          :decimal(, )      not null
#
# Indexes
#
#  index_user_tariff_prices_on_user_tariff_id  (user_tariff_id)
#
class UserTariffPrice < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_prices

  validates :start_time, :end_time, :value, :units, presence: true
end
