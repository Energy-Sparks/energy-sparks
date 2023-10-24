FactoryBot.define do
  factory :transport_survey do
    school
    run_on { Time.zone.today }
  end
end
