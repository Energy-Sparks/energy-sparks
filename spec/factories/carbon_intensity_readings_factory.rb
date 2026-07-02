require 'dashboard'

FactoryBot.define do
  factory :carbon_intensity_reading, class: 'DataFeeds::CarbonIntensityReading' do
    reading_date { 1.month.ago }
    carbon_intensity_x48 { Array.new(48, rand.to_f) }
  end
end
