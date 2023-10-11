FactoryBot.define do
  factory :scoreboard do
    sequence(:name) { |n| "Scoreboard #{n}" }
    academic_year_calendar { create(:calendar, :with_academic_years) }
  end
end
