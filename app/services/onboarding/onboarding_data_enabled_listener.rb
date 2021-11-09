module Onboarding
  class OnboardingDataEnabledListener
    def school_data_enabled(school)
      ActivationEmailSender.new(school).send
    end
  end
end
