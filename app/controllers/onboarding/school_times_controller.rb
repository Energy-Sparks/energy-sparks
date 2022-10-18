module Onboarding
  class SchoolTimesController < BaseController
    def edit
      @school = @school_onboarding.school
    end

    def update
      @school = @school_onboarding.school
      @school.attributes = school_params
      saved = false
      @school.school_times.each do |st|
        saved |= st.save
        puts "SAVED?"
        puts saved
      end
      if saved #@school.save(context: :school_time_update)
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'opening-times')
      else
        render :edit
      end
    end

  private

    def school_params
      params.require(:school).permit(
        school_times_attributes: [:id, :day, :opening_time, :closing_time, :calendar_period, :usage_type]
      )
    end
  end
end
