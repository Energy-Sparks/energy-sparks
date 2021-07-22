FactoryBot.define do
  factory :school_target do
    school
    start_date { Date.today.beginning_of_month }
    target_date { Date.today.beginning_of_month.next_year }
    electricity { rand(1..10) }
    gas { rand(1..10) }
    storage_heaters { rand(1..10) }
  end
end
