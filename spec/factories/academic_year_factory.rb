FactoryBot.define do
  factory :academic_year do
    start_date { 6.months.ago }
    end_date { 6.months.from_now }
  end
end
