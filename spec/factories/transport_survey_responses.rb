FactoryBot.define do
  factory :transport_survey_response do
    transport_survey
    transport_type
    device_identifier { "1234567890" }
    surveyed_at { DateTime.now }
    journey_minutes { 1 }
    weather { :sun }
  end
end
