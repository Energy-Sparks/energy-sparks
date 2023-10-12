module Onboarding
  class ReminderMailer
    THRESHOLD_DAYS = 7

    class << self
      def deliver_due
        deliver(school_onboardings: onboardings_with_reminders_due)
      end

      def deliver(school_onboardings:)
        onboardings_by_email(school_onboardings).each do |email, onboardings_for_email|
          OnboardingMailer.with(email: email, school_onboardings: onboardings_for_email).reminder_email.deliver_now
          create_events_for(onboardings_for_email)
        end
      end

      private

      def onboardings_with_reminders_due
        # The reminders should be sent one week after the initial onboarding email was sent,
        # and then weekly after the last reminder until the onboarding is completed.
        time = THRESHOLD_DAYS.days.ago
        SchoolOnboarding.incomplete.select do |onboarding|
          onboarding.last_event_older_than?(:reminder_sent, time) ||
            (onboarding.last_event_older_than?(:email_sent, time) && !onboarding.has_event?(:reminder_sent))
        end
      end

      def onboardings_by_email(school_onboardings)
        # Build hash of email addresses mapping to array of onboardings that match the same email
        school_onboardings.reduce({}) do |memo, school_onboarding|
          (memo[school_onboarding.contact_email] ||= []) << school_onboarding
          memo
        end
      end

      def create_events_for(onboardings_for_email)
        onboardings_for_email.each do |school_onboarding|
          school_onboarding.events.create!(event: :reminder_sent)
        end
      end
    end
  end
end
