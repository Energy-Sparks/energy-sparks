# == Schema Information
#
# Table name: user_tariff_prices
#
#  created_at     :datetime         not null
#  end_time       :time             default(Sat, 01 Jan 2000 23:30:00 UTC +00:00), not null
#  id             :bigint(8)        not null, primary key
#  start_time     :time             default(Sat, 01 Jan 2000 00:00:00 UTC +00:00), not null
#  units          :text             not null
#  updated_at     :datetime         not null
#  user_tariff_id :bigint(8)        not null
#  value          :decimal(, )      not null
#
# Indexes
#
#  index_user_tariff_prices_on_user_tariff_id  (user_tariff_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_tariff_id => user_tariffs.id) ON DELETE => cascade
#
class UserTariffPrice < ApplicationRecord
  belongs_to :user_tariff, inverse_of: :user_tariff_prices

  validates :start_time, :end_time, :value, :units, presence: true
  validates :value, numericality: true

  scope :by_start_time, -> { order(start_time: :asc) }
end
