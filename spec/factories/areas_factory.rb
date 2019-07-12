FactoryBot.define do
  factory :solar_pv_tuos_area, class: 'SolarPvTuosArea' do
    sequence(:title) {|n| "Solar PV TUOS Area #{n}"}
  end
  factory :weather_underground_area, class: 'WeatherUndergroundArea' do
    sequence(:title) {|n| "Weather Underground Area #{n}"}
  end

  factory :dark_sky_area, class: 'DarkSkyArea' do
    sequence(:title) {|n| "Dark Sky Area #{n}"}
  end
end

