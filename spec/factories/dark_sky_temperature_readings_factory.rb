require 'dashboard'

FactoryBot.define do
  factory :dark_sky_temperature_reading, class: 'DataFeeds::DarkSkyTemperatureReading' do
    dark_sky_area
    reading_date            { 1.month.ago }
    temperature_celsius_x48 { Array.new(48, rand.to_f) }
  end
end
