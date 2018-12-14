module Onboarding
  class SchoolTimesController < ApplicationController
    def edit
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @school = @school_onboarding.school
    end

    def update
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @school = @school_onboarding.school
      @school.attributes = school_params
      if @school.save(context: :school_times_update)
        redirect_to new_onboarding_completion_path(@school_onboarding.uuid)
      else
        render :edit
      end
    end

  private

    def school_params
      params.require(:school).permit(
        school_times_attributes: [:id, :day, :opening_time, :closing_time]
      )
    end
  end
end
