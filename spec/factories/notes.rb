FactoryBot.define do
  factory :note do
    school
    issue { false }
    title { "A title" }
    description { "A description" }
    status { :open }
    created_by { association :user }
    updated_by { association :user }
  end
end
