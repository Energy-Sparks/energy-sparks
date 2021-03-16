FactoryBot.define do
  factory :consent_grant do
    consent_statement
    school
    association :user, factory: :school_admin
  end
end
