# == Schema Information
#
# Table name: transport_types
#
#  can_share         :boolean          default(FALSE), not null
#  category          :integer          default("active_travel"), not null
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  image             :string           not null
#  kg_co2e_per_km    :decimal(, )      default(0.0), not null
#  name              :string           not null
#  note              :string
#  park_and_stride   :boolean          default(FALSE), not null
#  speed_km_per_hour :decimal(, )      default(0.0), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_transport_types_on_name  (name) UNIQUE
#
class TransportType < ApplicationRecord
  has_many :responses, class_name: 'TransportSurveyResponse', inverse_of: :transport_type

  validates :name, :image, :speed_km_per_hour, :kg_co2e_per_km, presence: true
  validates :kg_co2e_per_km, :speed_km_per_hour, numericality: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: true

  enum category: [:active_travel, :car, :public_transport]

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Transport type has associated responses' if responses.any?
    destroy
  end
end
