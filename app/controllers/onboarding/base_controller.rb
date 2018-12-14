module Onboarding
  class BaseController < ApplicationController
    before_action :load_school_onboarding


  private

    def load_school_onboarding
      @school_onboarding = if current_user
                             current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
                           else
                             SchoolOnboarding.find_by_uuid!(params[:onboarding_id])
                           end
      authorize! :manage, @school_onboarding
    end
  end
end
