# == Schema Information
#
# Table name: transport_types
#
#  can_share         :boolean          default(FALSE), not null
#  category          :integer
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  image             :string           not null
#  kg_co2e_per_km    :decimal(, )      default(0.0), not null
#  name              :string
#  note              :string
#  park_and_stride   :boolean          default(FALSE), not null
#  position          :integer          default(0), not null
#  speed_km_per_hour :decimal(, )      default(0.0), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_transport_types_on_name  (name) UNIQUE
#
class TransportSurvey::TransportType < ApplicationRecord
  self.table_name = 'transport_types'

  extend Mobility
  include TransifexSerialisable

  translates :name, type: :string, fallbacks: { cy: :en }

  has_many :responses, inverse_of: :transport_type

  scope :by_position, -> { order(position: :asc) }

  validates :name, :image, :speed_km_per_hour, :kg_co2e_per_km, :position, presence: true
  validates :kg_co2e_per_km, :speed_km_per_hour, :position, numericality: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: true

  enum :category, { walking_and_cycling: 0, car: 1, public_transport: 2, park_and_stride: 3 }

  def self.app_data
    all.select(:id, :name, :image, :kg_co2e_per_km, :speed_km_per_hour, :can_share, :park_and_stride).index_by(&:id)
  end

  def self.categories_with_other
    categories.merge(other: nil)
  end

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Transport type has associated responses' if responses.any?

    destroy
  end

  # override default name for this resource in transifex
  def tx_name
    name
  end

  # override default key and slug to use original name pre-moving to module
  # keeps in sync with the data already in transifex
  def resource_key
    "transport_type_#{id}"
  end
end
