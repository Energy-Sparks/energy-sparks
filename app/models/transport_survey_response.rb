# == Schema Information
#
# Table name: transport_survey_responses
#
#  created_at          :datetime         not null
#  device_identifier   :string           not null
#  id                  :bigint(8)        not null, primary key
#  journey_minutes     :integer          default(0), not null
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
class TransportSurveyResponse < ApplicationRecord
  belongs_to :transport_survey
  belongs_to :transport_type

  # Until we decide if to use a table or not
  enum weather: [:sun, :rain, :icy, :snow]

  def self.weather_symbols
    { sun: '☀️', rain: '🌧️ ', icy: '❄️', snow: '❄️' }
  end

  def self.journey_minutes_options
    [5, 10, 15, 30, 60]
  end

  validates :transport_survey_id, :transport_type_id, :device_identifier, :surveyed_at, :journey_minutes, :weather, presence: true
  validates :journey_minutes, numericality: { greater_than_or_equal_to: 0 }

end
