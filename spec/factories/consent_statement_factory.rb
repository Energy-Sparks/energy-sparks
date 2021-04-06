FactoryBot.define do
  factory :consent_statement do
    sequence(:title)        { |n| "Consent Statement #{n}"}
    sequence(:content)  { |n| "I grant thee consent #{n}"}
  end
end
