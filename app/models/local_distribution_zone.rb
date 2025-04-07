# frozen_string_literal: true

# == Schema Information
#
# Table name: local_distribution_zones
#
#  code           :string           not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  publication_id :string           not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_local_distribution_zones_on_code            (code) UNIQUE
#  index_local_distribution_zones_on_name            (name) UNIQUE
#  index_local_distribution_zones_on_publication_id  (publication_id) UNIQUE
#
class LocalDistributionZone < ApplicationRecord
  has_many :readings, dependent: :destroy, class_name: :LocalDistributionZoneReading

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :publication_id, presence: true, uniqueness: true

  scope :by_name, -> { order(:name) }

  AVERAGE_CALORIFIC_VALUE = 39.075
  MEGAJOULES_TO_KWH = 1 / (1.hour / 1000.0)
  CORRECTION_FACTOR = 1.02264 # https://www.eonnext.com/business/help/convert-gas-units-to-kwh

  def self.kwh_per_m3(local_distribution_zone, date)
    calorific_value = unless local_distribution_zone.nil? || date.nil?
                        local_distribution_zone.readings.find_by(date: date)&.calorific_value
                      end
    calorific_value = AVERAGE_CALORIFIC_VALUE if calorific_value.nil?
    calorific_value * MEGAJOULES_TO_KWH * CORRECTION_FACTOR
  end
end
