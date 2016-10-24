FactoryGirl.define do
  factory :school do
    sequence(:urn)
    name 'test school'
    school_type :primary
    enrolled true
  end
end
