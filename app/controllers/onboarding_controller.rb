# frozen_string_literal: true

class OnboardingController < Onboarding::BaseController
  include ApplicationHelper

  skip_before_action :authenticate_user!

  def show; end

  def success_icon(success)
    fa_icon(success ? 'check-circle text-success' : 'times-circle text-secondary')
  end
  helper_method :success_icon
end
