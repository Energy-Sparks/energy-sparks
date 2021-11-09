module Onboarding
  class OnboardingListener
    def onboarding_school_made_visible(school)
      ActivationEmailSender.new(school).send
    end
  end
end
