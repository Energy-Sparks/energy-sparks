# == Schema Information
#
# Table name: user_tariff_charges
#
#  charge_type    :text             not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  units          :text             not null
#  updated_at     :datetime         not null
#  user_tariff_id :bigint(8)        not null
#  value          :decimal(, )      not null
#
# Indexes
#
#  index_user_tariff_charges_on_user_tariff_id  (user_tariff_id)
#
class UserTariffCharge < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_charges

  validates :charge_type, :value, :units, presence: true
end
