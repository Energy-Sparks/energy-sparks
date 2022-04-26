# == Schema Information
#
# Table name: transport_survey_responses
#
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  integer             :integer          default(1), not null
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
class TransportSurveyResponse < ApplicationRecord
  belongs_to :transport_survey
  belongs_to :transport_type, inverse_of: :responses

  # Until we decide if to use a table or not
  enum weather: [:sun, :cloud, :rain, :snow]

  # These class helper methods may not stay here. They are currently helping with prototyping!
  def self.weather_symbols
    { sun: '☀️', cloud: '⛅', rain: '🌧️', snow: '❄️' }
  end

  def self.journey_minutes_options
    [5, 10, 15, 30, 60]
  end

  def self.passengers_options
    [1, 2, 3, 4]
  end

  def weather_symbol
    self.class.weather_symbols[weather.to_sym]
  end

  validates :transport_survey_id, :transport_type_id, :passengers, :run_identifier, :surveyed_at, :journey_minutes, :weather, presence: true
  validates :journey_minutes, inclusion: { in: journey_minutes_options }
  validates :passengers, inclusion: { in: passengers_options }
end
