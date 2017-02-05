FactoryGirl.define do
  factory :activity_type do
    activity_category
    name 'test activity_type name'
    score 25
    description 'test_activity_type description'
  end
end
