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
      # if using multiple issues with this trait, tag_labels must be specified, and be unique
      transient do
        tags_count { 1 }
        tag_labels { ['issue tag 1'] }
      end

      after(:create) do |issue, evaluator|
        evaluator.tags_count.times do |i|
          t = create(:issue_tag, label: evaluator.tag_labels[i])
          issue.issue_tags << t
        end
      end
    end

    trait :with_group_review do
      after(:create) do |issue|
        t = create(:issue_tag, system_id: :group_review)
        issue.issue_tags << t
      end
    end
  end
end
