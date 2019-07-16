# frozen_string_literal: true

module Onboarding
  class BaseController < ApplicationController
    before_action :load_school_onboarding
    before_action :check_complete
    before_action :hide_subnav

    private

    def load_school_onboarding
      @school_onboarding = if current_user
                             current_user.school_onboardings.find_by_uuid!(params.fetch(:onboarding_id) { params[:id] })
                           else
                             SchoolOnboarding.find_by_uuid!(params.fetch(:onboarding_id) { params[:id] })
                           end
      authorize! :manage, @school_onboarding
    end

    def redirect_if_event(event, path)
      redirect_to path if @school_onboarding.has_event?(event)
    end

    def check_complete
      redirect_if_event(:onboarding_complete, onboarding_completion_path(@school_onboarding))
    end

    def hide_subnav
      @hide_subnav = true
    end
  end
end
