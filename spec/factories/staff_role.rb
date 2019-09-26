FactoryBot.define do
  factory :staff_role do
    sequence(:title) {|n| "Staffrole#{n}"}
  end
end
