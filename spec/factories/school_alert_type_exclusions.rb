FactoryBot.define do
  factory :school_alert_type_exclusion do
    school
    alert_type
    association :created_by, factory: [:admin]
    sequence(:reason) { |n| "Reason #{n}" }
  end
end
