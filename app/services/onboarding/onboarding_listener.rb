module Onboarding
  class OnboardingListener
    include OnboardingHelper
    include NewsletterSubscriber

    def school_made_visible(school)
      ActivationEmailSender.new(school).send
    end

    def onboarding_completed(school_onboarding, current_user)
      school_onboarding.events.create(event: :onboarding_complete)

      users = school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }

      send_confirmation_instructions(users)
      create_additional_contacts(school_onboarding, users)
      subscribe_users_to_newsletter(school_onboarding, school_onboarding.school.users.reject(&:pupil?))

      OnboardingMailer.with(school_onboarding: school_onboarding).completion_email.deliver_now
    end

    private

    def send_confirmation_instructions(users)
      #confirm other users created during onboarding
      users.each do |user|
        user.send_confirmation_instructions unless user.confirmed?
      end
    end

    def create_additional_contacts(school_onboarding, users)
      users.each do |user|
        school_onboarding.events.create(event: :alert_contact_created)
        school_onboarding.school.contacts.create!(
          user: user,
          name: user.display_name,
          email_address: user.email,
          description: 'School Energy Sparks contact'
        )
      end
    end

    def subscribe_users_to_newsletter(school_onboarding, users)
      users.each do |user|
        subscribe_newsletter(school_onboarding.school, user) if user_subscribed_to_newsletter?(school_onboarding, user)
      end
    end
  end
end
