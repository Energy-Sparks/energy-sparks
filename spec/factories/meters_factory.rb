FactoryBot.define do
  factory :meter do
    school
    sequence(:meter_no) { |n| n }
    meter_type :gas
    active { true }
  end
end
