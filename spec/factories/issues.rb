# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    issueable { create(:school) }
    issue_type { :issue }
    sequence(:title) {|n| "Title #{n}"}
    sequence(:description) {|n| "Description #{n}"}
    status { :open }
    fuel_type { :gas }
    created_by { association :user }
    updated_by { association :user }

    trait :with_tags do
      transient do
        tags_count { 1 }
      end

      after(:create) do |issue, evaluator|
        create_list(:issue_tag, evaluator.tags_count).each do |t|
          issue.issue_tags << t
        end
      end
    end
  end
end
