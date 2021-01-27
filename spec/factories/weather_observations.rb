FactoryBot.define do
  factory :weather_observation do
    weather_station { nil }
    reading_date { "2021-01-27" }
    temperature_celsius_x48 { "9.99" }
  end
end
