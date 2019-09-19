module Schools
  class SchoolGroupController < ApplicationController
    before_action :set_school, :set_groups

    def new
    end

    def create
      @school.update!(school_group_id: params[:school_group_id])
      redirect_to new_school_configuration_path(@school)
    end

    def edit
    end

    def update
      @school.update!(school_group_id: params[:school_group_id])
      redirect_to school_path(@school), notice: "School groups updated"
    end

  private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :group, @school
    end

    def set_groups
      @school_groups = if @school.template_calendar
                         SchoolGroup.includes(:scoreboard).where(scoreboards: { academic_year_calendar_id: @school.template_calendar.based_on_id }).order(:name)
                       else
                         SchoolGroup.order(:name)
                       end
    end
  end
end
