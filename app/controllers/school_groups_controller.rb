class SchoolGroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @school_groups = SchoolGroup.order(:name)
  end

  def show
  end
end
