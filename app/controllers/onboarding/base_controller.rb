module Onboarding
  class BaseController < ApplicationController
    before_action :load_school_onboarding


  private

    def load_school_onboarding
      @school_onboarding = if current_user
                             current_user.school_onboardings.find_by_uuid!(params.fetch(:onboarding_id) { params[:id] })
                           else
                             SchoolOnboarding.find_by_uuid!(params.fetch(:onboarding_id) { params[:id] })
                           end
      authorize! :manage, @school_onboarding
    end
  end
end
