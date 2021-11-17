module Onboarding
  class OnboardingListener
    def onboarding_completed(school_onboarding)
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
    end

    def school_made_visible(school)
      ActivationEmailSender.new(school).send
    end
  end
end
