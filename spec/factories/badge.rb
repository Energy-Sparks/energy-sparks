FactoryGirl.define do
  factory :badge, class: Merit::Badge do
    sequence(:id, 1000)
    name 'test-badge'
  end
end
