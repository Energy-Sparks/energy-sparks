FactoryBot.define do
  factory :transport_survey_response, class: 'TransportSurvey::Response' do
    transport_survey { create(:transport_survey) }
    transport_type { create(:transport_type) }
    run_identifier { TransportSurvey::Response.generate_unique_secure_token }
    surveyed_at { DateTime.now }
    journey_minutes { 5 }
    weather { :sun }
    passengers { 1 }
  end
end
