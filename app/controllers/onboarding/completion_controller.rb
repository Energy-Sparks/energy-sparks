module Onboarding
  class CompletionController < ApplicationController
    def new
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @school = @school_onboarding.school
      @meters = @school.meters
      @school_times = @school.school_times.sort_by {|time| SchoolTime.days[time.day]}
    end

    def create
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @school_onboarding.events.create(event: :onboarding_complete)
      redirect_to onboarding_completion_path(@school_onboarding.uuid)
    end

    def show
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
    end
  end
end
