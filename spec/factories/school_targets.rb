FactoryBot.define do
  factory :school_target do
    school
    target { Date.today.next_year }
    electricity { rand(1..10) }
    gas { rand(1..10) }
    storage_heaters { rand(1..10) }
  end
end
