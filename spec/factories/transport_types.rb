FactoryBot.define do
  factory :transport_type do
    sequence(:name) {|n| "name#{n}"}
    image { "🚗" }
    kg_co2e_per_km { "0.17137" }
    speed_km_per_hour { "32" }
    note { "Average car, unknown size or fuel type" }
    can_share { true }
  end
end
