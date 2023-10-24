require 'dashboard'

FactoryBot.define do
  factory :solar_pv_tuos_reading, class: 'DataFeeds::SolarPvTuosReading' do
    reading_date { 1.month.ago }
    generation_mw_x48 { Array.new(48, rand.to_f) }
  end
end
