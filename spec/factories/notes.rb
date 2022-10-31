FactoryBot.define do
  factory :note do
    school
    type { "Note" }
    title { "A title" }
    description { "A description" }
    status { :open }
    created_by { association :user }
    updated_by { association :user }
  end
end
