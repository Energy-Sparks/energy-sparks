class SchoolGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: :show

  def index
    @school_groups = SchoolGroup.by_name
  end

  def show
    @schools = @school_group.schools.visible.by_name
  end
end
