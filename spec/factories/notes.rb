FactoryBot.define do
  factory :note do
    school
    note_type { :note }
    sequence(:title) {|n| "Title #{n}"}
    sequence(:description) {|n| "Description #{n}"}
    status { :open }
    created_by { association :user }
    updated_by { association :user }
  end
end
