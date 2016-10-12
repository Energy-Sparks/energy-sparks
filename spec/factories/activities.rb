FactoryGirl.define do
  factory :activity do
    school
    activity_type
    title 'test activity title'
    description 'test activity description'
    happened_on { Date.today - 1.days }
  end
end
