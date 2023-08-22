# == Schema Information
#
# Table name: energy_tariff_prices
#
#  created_at       :datetime         not null
#  description      :text
#  end_time         :text             not null
#  energy_tariff_id :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  start_time       :text             not null
#  units            :text
#  updated_at       :datetime         not null
#  value            :decimal(, )      default(0.0), not null
#
# Indexes
#
#  index_energy_tariff_prices_on_energy_tariff_id  (energy_tariff_id)
#
class EnergyTariffPrice < ApplicationRecord
  MINIMUM_VALUE = 0.0
  NIGHT_RATE_DESCRIPTION = 'Night rate'.freeze
  DAY_RATE_DESCRIPTION = 'Day rate'.freeze

  belongs_to :energy_tariff, inverse_of: :energy_tariff_prices

  validates :start_time, :end_time, :units, presence: true
  validates :value, presence: true, on: :update

  validates :value, numericality: { greater_than: MINIMUM_VALUE }, allow_nil: true, on: :create
  validates :value, numericality: { greater_than: MINIMUM_VALUE }, on: :update
  validate :no_time_overlaps
  validate :time_range_given

  scope :by_start_time, -> { order(start_time: :asc) }

  def time_range
    last_time = end_time < start_time ? end_time + 1.day : end_time
    start_time + 1.minute..last_time - 1.minute
  end

  def time_duration
    range = time_range
    ((range.last - range.first) / 1.minute) + 2
  end

  def self.total_minutes
    all.map(&:time_duration).sum
  end

  def self.complete?
    return true if first&.energy_tariff&.flat_rate?

    total_minutes == 1440
  end

  private

  def no_time_overlaps
    energy_tariff&.energy_tariff_prices&.without(self)&.each do |other_price|
      errors.add(:start_time, 'overlaps with another time range') if other_price.time_range.include?(start_time)
      errors.add(:end_time, 'overlaps with another time range') if other_price.time_range.include?(end_time)
    end
  end

  def time_range_given
    errors.add(:start_time, "can't be the same as end time") if start_time == end_time
  end
end
