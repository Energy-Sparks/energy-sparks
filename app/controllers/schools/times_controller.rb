module Schools
  class TimesController < ApplicationController
    before_action :set_school

    def edit
      @school_times = @school.school_times.build(opening_time: nil, closing_time: nil, usage_type: :community_use)
    end

    def update
      @school.attributes = school_params
      if @school.save(context: :school_times_update)
        redirect_to edit_school_times_path(@school), notice: 'School times updated'
      else
        render :edit
      end
    end

  private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :manage_school_times, @school
    end

    def school_params
      params.require(:school).permit(
        school_times_attributes: [:id, :day, :opening_time, :closing_time, :term_time_only, :usage_type]
      )
    end
  end
end
