module Onboarding
  class OnboardingDataEnabledListener
    def onboarding_completed(school_onboarding)
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      school.update!(visible: true)
      ActivationEmailSender.new(school).send
    end

    def school_made_visible(school)
    end

    def school_made_data_enabled(school)
      ActivationEmailSender.new(school).send
    end
  end
end
