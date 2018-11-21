module Schools
  class SchoolGroupController < ApplicationController
    before_action :set_school

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
      authorize! :manage, @school
    end
  end
end
