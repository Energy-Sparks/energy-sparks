FactoryBot.define do
  factory :meter_review do
    school factory: :school
    user factory: :admin
    consent_grant factory: :consent_grant
  end
end
