FactoryBot.define do
  factory :observation do
    school
    at     { Time.now.utc }
  end
end
