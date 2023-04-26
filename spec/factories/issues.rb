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
  end
end
