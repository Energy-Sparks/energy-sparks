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

      def edit
      end

      def update
        if @school_onboarding.update(school_params)
          OnboardingMailer.with(school_onboarding: @school_onboarding).onboarding_email.deliver_now
          redirect_to admin_school_onboardings_path
        else
          render :edit
        end
      end

    private

      def school_params
        params.require(:school_onboarding).permit(
          :contact_email,
          :notes,
        )
      end
    end
  end
end
