class OnboardingController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @school_onboarding = SchoolOnboarding.find_by_uuid!(params[:id])
  end
end
