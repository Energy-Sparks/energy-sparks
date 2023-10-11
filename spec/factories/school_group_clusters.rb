FactoryBot.define do
  factory :school_group_cluster do
    school_group
    sequence(:name) { |n| "cluster name #{n}" }
  end
end
