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
end
