module Onboarding
  class OnboardingListener
    include OnboardingHelper
    include NewsletterSubscriber

    def school_made_visible(school)
      if should_complete_onboarding?(school)
        users = school.users.reject(&:pupil?)
        complete_onboarding(school.school_onboarding, users)
      end
      ActivationEmailSender.new(school).send
    end

    def onboarding_completed(school_onboarding, current_user)
      users = school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }
      complete_onboarding(school_onboarding, users)
    end
  end
end
