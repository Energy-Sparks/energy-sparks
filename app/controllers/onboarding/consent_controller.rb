module Onboarding
  class ConsentController < BaseController
    skip_before_action :authenticate_user!
    before_action do
      redirect_if_event(:permission_given, new_onboarding_account_path(@school_onboarding))
    end

    def show
      @school_onboarding_consent = SchoolOnboardingConsent.new
    end

    def create
      @school_onboarding_consent = SchoolOnboardingConsent.new(school_onboarding_consent_params)

      if @school_onboarding_consent.valid?
        @school_onboarding.events.create!(event: :privacy_policy_agreed)
        @school_onboarding.events.create!(event: :permission_given)

        redirect_to new_onboarding_account_path(@school_onboarding)
      else
        render :show
      end
    end

  private

    def school_onboarding_consent_params
      params.require(:school_onboarding_consent).permit(:privacy)
    end
  end
end
