module Onboarding
  class BaseController < ApplicationController
    before_action :load_school_onboarding
    before_action :check_complete
    before_action :hide_subnav

    private

    def load_school_onboarding
      @school_onboarding = SchoolOnboarding.find_by!(uuid: params.fetch(:onboarding_id) { params[:id] })
      authorize! :manage, @school_onboarding
    rescue StandardError => e
      store_location_for(:user, onboarding_path(@school_onboarding))
      redirect_to new_user_session_path, notice: message(@school_onboarding, e)
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

    def message(school_onboarding, exception)
      if current_user.nil? && school_onboarding.created_user.present?
        'You must sign in to resume the onboarding process'
      else
        exception.message
      end
    end
  end
end
