FactoryBot.define do
  factory :transport_survey_response do
    transport_survey
    transport_type
    run_identifier { "1234567890" }
    surveyed_at { DateTime.now }
    journey_minutes { 1 }
    weather { :sun }
    passengers { 1 }
  end
end
