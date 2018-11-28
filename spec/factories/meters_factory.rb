FactoryBot.define do
  factory :gas_meter, class: 'Meter'do
    school
    sequence(:mpan_mprn) { |n| n }
    meter_type :gas
    active { true }
  end

  factory :electricity_meter, class: 'Meter' do
    school
    sequence(:mpan_mprn) { |n| "10#{sprintf('%011d', n)}" }
    meter_type :electricity
    active { true }
  end
end
