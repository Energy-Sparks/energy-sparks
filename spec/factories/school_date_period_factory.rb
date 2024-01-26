FactoryBot.define do
  factory :school_date_period do
    type  { :summer }
    sequence(:title) { |n| "Period #{n}" }
    start_date { Time.zone.today - 7 }
    end_date { Time.zone.today }

    initialize_with { new(type, title, start_date, end_date) }
  end
end
