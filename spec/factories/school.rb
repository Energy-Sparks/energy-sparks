FactoryGirl.define do
  factory :school do
    sequence(:urn)
    name 'test school'
    school_type :primary
    enrolled true
    postcode 'ab1 2cd'
  end
end
