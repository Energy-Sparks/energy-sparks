FactoryBot.define do
  factory :note do
    school
    note_type { :note }
    title { "A title" }
    description { "A description" }
    status { :open }
    created_by { association :user }
    updated_by { association :user }
  end
end
