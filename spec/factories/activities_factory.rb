FactoryBot.define do
  factory :activity do
    school
    activity_type
    activity_category
    title             { 'test activity title' }
    description       { 'test activity description' }
    happened_on       { Date.today - 1.days }
  end
end
