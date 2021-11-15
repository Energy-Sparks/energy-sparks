module Onboarding
  class OnboardingListener
    include OnboardingHelper
    include NewsletterSubscriber

    def school_made_visible(school)
      if should_complete_onboarding?(school)
        record_event(@school.school_onboarding, :onboarding_complete)
        enrol_in_default_programme
      end
      if should_send_activation_email?(school)
        ActivationEmailSender.new(school).send
      end
    end

    def onboarding_completed(school_onboarding, current_user)
      school_onboarding.events.create(event: :onboarding_complete)

      users = school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }

      send_confirmation_instructions(users)
      create_additional_contacts(school_onboarding, users)
      subscribe_users_to_newsletter(school_onboarding, school_onboarding.school.users.reject(&:pupil?))

      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
    end
  end
end
