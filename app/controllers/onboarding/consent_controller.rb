module Onboarding
  class ConsentController < BaseController
    skip_before_action :authenticate_user!

    def show
      @school_onboarding = SchoolOnboarding.find_by_uuid!(params[:onboarding_id])
    end

    def create
      school_onboarding = SchoolOnboarding.find_by_uuid!(params[:onboarding_id])
      school_onboarding.events.create!(event: :permission_given)
      redirect_to new_onboarding_account_path(school_onboarding)
    end
  end
end
