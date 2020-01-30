FactoryBot.define do
  factory :resource_file_type do
    sequence(:title)  { |n| "Resource type #{n}" }
    sequence(:position)
  end
end
