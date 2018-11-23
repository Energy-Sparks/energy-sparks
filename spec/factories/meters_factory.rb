FactoryBot.define do
  factory :meter do
    school
    sequence(:mpan_mprn) { |n| n }
    meter_type :gas
    active { true }
  end
end
