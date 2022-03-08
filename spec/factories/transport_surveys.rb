FactoryBot.define do
  factory :transport_survey do
    school
    run_on { Date.today }
  end
end
