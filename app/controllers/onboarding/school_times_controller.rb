# frozen_string_literal: true

module Onboarding
  class SchoolTimesController < BaseController
    def edit
      @school = @school_onboarding.school
    end

    def update
      @school = @school_onboarding.school
      @school.attributes = school_params
      if @school.save(context: :school_times_update)
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'opening-times')
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
