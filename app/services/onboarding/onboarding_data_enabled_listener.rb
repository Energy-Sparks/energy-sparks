module Onboarding
  class OnboardingDataEnabledListener
    def onboarding_completed(school_onboarding)
      school.update!(data_enabled: false)
      school.update!(visible: true)
      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
      OnboardedEmailSender.new(school).send
    end

    def school_made_visible(school)
    end

    def school_made_data_enabled(school)
      DataEnabledEmailSender.new(school).send
    end
  end
end
