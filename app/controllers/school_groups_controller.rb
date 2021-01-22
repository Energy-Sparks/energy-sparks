class SchoolGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:show, :map]

  def index
    @school_groups = SchoolGroup.by_name
  end

  def show
    # set the school group id for the JS to use in map calls
    gon.school_group_id = @school_group.id
    @schools = @school_group.schools.visible.by_name
  end

  def map
    @schools = @school_group.schools.visible.by_name
    respond_to do |format|
      format.html
      format.json { render json: Maps::Features.new(@schools).as_json, status: :ok }
    end
  end
end
