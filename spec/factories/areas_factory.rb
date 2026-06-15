FactoryBot.define do
  factory :solar_pv_tuos_area, class: 'SolarPvTuosArea' do
    sequence(:title) { |n| "Solar PV TUOS Area #{n}" }
    latitude         { 123.456 }
    longitude        { 789.101 }
    gsp_id           { 199 }
    gsp_name         { 'ABC' }
    active           { true }
  end

  factory :dark_sky_area, class: 'DarkSkyArea' do
    sequence(:title) { |n| "Dark Sky Area #{n}" }
    latitude         { 123.456 }
    longitude        { 789.101 }
    active           { true }
  end
end
