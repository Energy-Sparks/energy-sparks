# frozen_string_literal: true

class OnboardingController < Onboarding::BaseController
  skip_before_action :authenticate_user!

  def show
  end
end
