FactoryBot.define do
  factory :academic_year do
    start_date { 6.months.ago }
    end_date { 6.months.from_now }
    association :calendar, :with_terms
  end
end
