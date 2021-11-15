module Onboarding
  class OnboardingDataEnabledListener
    include OnboardingHelper
    include NewsletterSubscriber

    def school_made_visible(school)
    end

    def onboarding_completed(school_onboarding, current_user)
      school.update!(visible: true)
      users = school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }
      complete_onboarding(school_onboarding, users)
    end

    def school_made_data_enabled(school)
      ActivationEmailSender.new(school).send
    end
  end
end
