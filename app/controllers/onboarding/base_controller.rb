module Onboarding
  class BaseController < ApplicationController
    before_action :load_school_onboarding
    before_action :check_complete
    before_action :hide_subnav

  private

    def load_school_onboarding
      @school_onboarding = SchoolOnboarding.find_by_uuid!(params.fetch(:onboarding_id) { params[:id] })
      authorize! :manage, @school_onboarding
    end

    def redirect_if_event(event, path)
      if @school_onboarding.has_event?(event)
        redirect_to path
      end
    end

    def check_complete
      redirect_if_event(:onboarding_complete, onboarding_completion_path(@school_onboarding))
    end

    def hide_subnav
      @hide_subnav = true
    end
  end
end
