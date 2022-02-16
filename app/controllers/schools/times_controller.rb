module Schools
  class TimesController < ApplicationController
    before_action :set_school

    def edit
    end

    def update
      @school.attributes = school_params
      if @school.save(context: :school_times_update)
        redirect_to edit_school_times_path(@school), notice: 'School times have been updated'
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
        school_times_attributes: [:id, :day, :opening_time, :closing_time, :calendar_period, :usage_type, :_destroy]
      )
    end
  end
end
