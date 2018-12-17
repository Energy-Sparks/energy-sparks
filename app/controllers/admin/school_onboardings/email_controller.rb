module Admin
  module SchoolOnboardings
    class EmailController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def new
      end

      def create
        OnboardingMailer.with(school_onboarding: @school_onboarding).onboarding_email.deliver_now
        @school_onboarding.events.create!(event: :email_sent)
        redirect_to admin_school_onboardings_path
      end
    end
  end
end
