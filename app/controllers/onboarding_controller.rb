class OnboardingController < Onboarding::BaseController
  skip_before_action :authenticate_user!

  def show; end
end
