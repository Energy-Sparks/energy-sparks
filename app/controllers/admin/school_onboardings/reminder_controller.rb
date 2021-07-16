module Admin
  module SchoolOnboardings
    class ReminderController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def create
        OnboardingMailer.with(school_onboarding: @school_onboarding).reminder_email.deliver_now
        @school_onboarding.events.create!(event: :reminder_sent)
        redirect_to admin_school_onboardings_path(anchor: params[:school_group])
      end
    end
  end
end
