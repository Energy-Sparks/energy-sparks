# == Schema Information
#
# Table name: transport_survey_responses
#
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  journey_minutes     :integer          default(0), not null
#  passengers          :integer          default(1), not null
#  run_identifier      :string           not null
#  surveyed_at         :datetime         not null
#  transport_survey_id :bigint(8)        not null
#  transport_type_id   :bigint(8)        not null
#  updated_at          :datetime         not null
#  weather             :integer          default("sun"), not null
#
# Indexes
#
#  index_transport_survey_responses_on_transport_survey_id  (transport_survey_id)
#  index_transport_survey_responses_on_transport_type_id    (transport_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (transport_survey_id => transport_surveys.id) ON DELETE => cascade
#  fk_rails_...  (transport_type_id => transport_types.id)
#
class TransportSurvey::Response < ApplicationRecord
  extend ActiveModel::Translation
  include CsvExportable

  belongs_to :transport_survey
  belongs_to :transport_type, inverse_of: :responses

  scope :with_transport_type, -> { joins(:transport_type) }

  def self.journey_minutes_options
    [5, 10, 15, 20, 30, 45, 60]
  end

  def self.passengers_options
    [1, 2, 3, 4, 5, 6]
  end

  validates :transport_survey_id, :transport_type_id, :passengers, :run_identifier, :surveyed_at, :journey_minutes,
            :weather, presence: true
  validates :journey_minutes, inclusion: { in: journey_minutes_options }
  validates :passengers, inclusion: { in: passengers_options }

  enum :weather, { sun: 0, cloud: 1, rain: 2, snow: 3 }

  def self.weather_images
    { sun: '☀️', cloud: '⛅', rain: '🌧️', snow: '❄️' }
  end

  def weather_image
    self.class.weather_images[weather.to_sym]
  end

  def weather_name
    self.class.human_enum_name(:weather, weather)
  end

  def self.passenger_symbol
    '👤'
  end

  def self.park_and_stride_mins
    10
  end

  def self.csv_attributes
    %w[id run_identifier weather_name journey_minutes transport_type.name passengers carbon_kg_co2 surveyed_at]
  end

  def carbon_kg_co2
    carbon.round(3)
  end

  def carbon
    transport_type.can_share? ? (carbon_calc / passengers) : carbon_calc
  end

  private

  def carbon_calc
    ((transport_type.speed_km_per_hour * journey_mins_ps) / 60) * transport_type.kg_co2e_per_km
  end

  # take specified amount of minutes off journey time for park and stride transport types
  def journey_mins_ps
    if transport_type.park_and_stride == true
      (journey_minutes > self.class.park_and_stride_mins ? journey_minutes - self.class.park_and_stride_mins : 0)
    else
      journey_minutes
    end
  end
end
