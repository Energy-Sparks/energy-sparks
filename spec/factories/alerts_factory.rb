FactoryBot.define do
  factory :alert do
    school
    alert_type
    run_on { Date.today }
    rating { 5.0 }
    priority_data do
      { 'time_of_year_relevance' => 5.0 }
    end

    trait :with_run do
      alert_generation_run { FactoryBot.build(:alert_generation_run, school: school) }
    end
  end
end
