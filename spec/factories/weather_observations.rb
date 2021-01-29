FactoryBot.define do
  factory :weather_observation do
    weather_station
    reading_date            { 1.month.ago }
    temperature_celsius_x48 { Array.new(48, rand.to_f) }
  end
end
