module Schools
  class SchoolGroupController < ApplicationController
    before_action :set_school, :set_groups

    def new
    end

    def create
      @school.update!(school_group_id: params[:school_group_id])
      redirect_to new_school_configuration_path(@school)
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :group, @school
    end

    def set_groups
      @school_groups = SchoolGroup.order(:name)
    end
  end
end
