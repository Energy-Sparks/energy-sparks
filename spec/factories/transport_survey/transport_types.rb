FactoryBot.define do
  factory :transport_type, class: 'TransportSurvey::TransportType' do
    sequence(:name) {|n| "name#{n}"}
    image { '🚗' }
    kg_co2e_per_km { '0.17137' }
    speed_km_per_hour { '32' }
    note { 'Average car, unknown size or fuel type' }
    category { :car }
    can_share { true }
    park_and_stride { false }
    position { 0 }
  end
end
