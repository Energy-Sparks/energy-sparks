# == Schema Information
#
# Table name: user_tariff_prices
#
#  created_at     :datetime         not null
#  description    :string
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
  validate :no_time_overlaps
  validate :time_range_given

  scope :by_start_time, -> { order(start_time: :asc) }

  NIGHT_RATE_DESCRIPTION = 'Night rate'.freeze
  DAY_RATE_DESCRIPTION = 'Day rate'.freeze

  def time_range
    first = start_time + 1.minute
    last = end_time < start_time ? end_time + 1.day : end_time
    first...last
  end

  private

  def no_time_overlaps
    self.user_tariff.user_tariff_prices.without(self).each do |other_price|
      errors.add(:start_time, 'overlaps with another time range') if other_price.time_range.include?(start_time)
      errors.add(:end_time, 'overlaps with another time range') if other_price.time_range.include?(end_time)
    end
  end

  def time_range_given
    errors.add(:start_time, "can't be the same as end time") if start_time == end_time
  end
end
