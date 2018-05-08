FactoryBot.define do
  factory :activity_type do
    activity_category
    sequence(:name) {|n| "test activity_type name #{n}"}
    score 25
    description 'test_activity_type description'
  end
end
