FactoryBot.define do
  factory :weather_station do
    sequence(:title) {|n| "Weather Station #{n}"}
    description { 'A weather station' }
    provider { 'meteostat' }
    active { true }
    latitude { 51.4667 }
    longitude { -2.6000 }

    trait :with_readings do
      transient do
        reading_start_date { 1.month.ago.to_date }
        reading_end_date { 1.day.ago.to_date }
        temperature_celsius_x48 { Array.new(48, rand.to_f) }
      end

      after(:create) do |weather_station, evaluator|
        (evaluator.reading_start_date..evaluator.reading_end_date).each do |reading_date|
          create(:weather_observation,
                 weather_station:,
                 reading_date:,
                 temperature_celsius_x48: evaluator.temperature_celsius_x48)
        end
      end
    end
  end
end
