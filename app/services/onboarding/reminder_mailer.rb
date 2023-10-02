module Onboarding
  class ReminderMailer
    class << self
      def send_due
        schools_by_email.each do |email, onboardings|
          OnboardingMailer.with(email: email, school_onboardings: onboardings).reminder_email.deliver_now
          create_events_for(onboardings)
        end
      end

      private

      def find_schools
        # The reminders should be sent one week after the initial onboarding email was sent,
        # and then weekly after the last reminder until the onboarding is completed.
        # (See the SchoolOnboardingEvents events for the dates)
        SchoolOnboarding.reminder_due
      end

      def schools_by_email
        # Build hash of email addresses mapping to array of onboardings that match the same email
        find_schools.reduce({}) { |memo, onboarding| (memo[onboarding.contact_email] ||= []) << onboarding }
      end

      def create_events_for(onboardings)
        onboardings.each do |onboarding|
          onboarding.events.create!(event: :reminder_sent)
        end
      end
    end
  end
end
