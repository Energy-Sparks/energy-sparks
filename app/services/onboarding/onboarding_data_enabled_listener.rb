module Onboarding
  class OnboardingDataEnabledListener
    def onboarding_completed(school_onboarding)
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      OnboardedEmailSender.new(school_onboarding.school).send
    end

    def school_made_data_enabled(school)
      DataEnabledEmailSender.new(school).send
    end
  end
end
