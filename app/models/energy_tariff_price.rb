# == Schema Information
#
# Table name: energy_tariff_prices
#
#  created_at       :datetime         not null
#  description      :text
#  end_time         :time             default(Sat, 01 Jan 2000 23:30:00.000000000 UTC +00:00), not null
#  energy_tariff_id :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  start_time       :time             default(Sat, 01 Jan 2000 00:00:00.000000000 UTC +00:00), not null
#  units            :text
#  updated_at       :datetime         not null
#  value            :decimal(, )
#
# Indexes
#
#  index_energy_tariff_prices_on_energy_tariff_id  (energy_tariff_id)
#
class EnergyTariffPrice < ApplicationRecord
  MINIMUM_VALUE = 0.0
  MAXIMUM_VALUE = 1.0

  belongs_to :energy_tariff, inverse_of: :energy_tariff_prices

  validates :start_time, :end_time, :units, presence: true
  validates :value, presence: true, on: :update

  NUMERICALITY_OPTIONS = { greater_than: MINIMUM_VALUE, less_than: MAXIMUM_VALUE }.freeze
  validates :value, numericality: NUMERICALITY_OPTIONS, allow_nil: true, on: :create
  validates :value, numericality: NUMERICALITY_OPTIONS, on: :update

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
    all.sum(&:time_duration)
  end

  def self.complete?
    return true if first&.energy_tariff&.flat_rate?

    total_minutes == 1440
  end

  def self.invalid_prices?
    all.map(&:value).any? { |value| value.nil? || value.zero? }
  end

  def self.possible_time_range_gaps
    return [] if complete?

    find_possible_time_range_gaps
  end

  def self.find_possible_time_range_gaps
    existing_time_ranges = all.order(:start_time).map(&:time_range)
    possible_time_range_gaps = []

    existing_time_ranges.each_with_index do |time_range, index|
      end_time_index = (index == existing_time_ranges.size - 1 ? 0 : index + 1)
      start_time = time_range.last + 1.minute
      end_time = existing_time_ranges[end_time_index].first - 1.minute
      next if start_time == end_time

      possible_time_range_gaps << (start_time..end_time)
    end

    possible_time_range_gaps
  end

  private

  def no_time_overlaps
    return if energy_tariff&.flat_rate?

    energy_tariff&.energy_tariff_prices&.without(self)&.each do |other_price|
      if other_price.time_range.cover?(start_time)
        errors.add(:start_time, I18n.t('energy_tariff_price.errors.overlaps_with_another_time_range'))
      end
      if other_price.time_range.cover?(end_time)
        errors.add(:end_time, I18n.t('energy_tariff_price.errors.overlaps_with_another_time_range'))
      end
    end
  end

  def time_range_given
    return if energy_tariff&.flat_rate?

    return unless start_time == end_time

    errors.add(:start_time, I18n.t('energy_tariff_price.errors.cannot_be_the_same_as_end_time'))
  end
end
