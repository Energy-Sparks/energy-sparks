module Onboarding
  class OnboardingDataEnabledListener
    def onboarding_completed(school_onboarding)
      school.update!(visible: true)
      school.update!(data_enabled: false)
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      ActivationEmailSender.new(school).send
    end

    def school_made_visible(school)
    end

    def school_made_data_enabled(school)
      ActivationEmailSender.new(school).send
    end
  end
end
