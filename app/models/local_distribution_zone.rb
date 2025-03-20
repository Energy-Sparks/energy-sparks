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

  KWH_PER_M3_GAS = 11.1 # this depends on the calorifc value of the gas and so is an approximate average
  MEGAJOULES_TO_KWH = 1 / (1.hour / 1000.0)

  def self.kwh_per_m3(zone, date)
    calorific_value = zone.readings.find_by(date: date)&.calorific_value unless zone.nil?
    calorific_value.nil? ? KWH_PER_M3_GAS : calorific_value * MEGAJOULES_TO_KWH
  end
end
