FactoryBot.define do
  factory :alert do
    school
    alert_type
    run_on { Date.today }
    rating { 5.0 }
    priority_data {
      {'time_of_year_relevance' => 5.0}
    }
    table_data { nil }

    trait :with_run do
      alert_generation_run { FactoryBot.build(:alert_generation_run, school: school) }
    end
  end
end
