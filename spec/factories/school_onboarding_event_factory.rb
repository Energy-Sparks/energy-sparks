FactoryBot.define do
  factory :school_onboarding_event do
    school_onboarding
    event { :email_sent }
  end
end
