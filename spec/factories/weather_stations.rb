FactoryBot.define do
  factory :weather_station do
    sequence(:title) {|n| "Weather Station #{n}"}
    description { 'A weather station' }
    provider { 'meteostat' }
    active { true }
    latitude { 51.4667 }
    longitude { -2.6000 }
  end
end
