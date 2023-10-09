module Admin
  module SchoolOnboardings
    class ReminderController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def create
        OnboardingMailer.with(onboardings: [@school_onboarding], email: @school_onboarding.contact_email).reminder_email.deliver_now
        @school_onboarding.events.create!(event: :reminder_sent)
        redirect_to admin_school_onboardings_path(anchor: @school_onboarding.page_anchor)
      end
    end
  end
end
