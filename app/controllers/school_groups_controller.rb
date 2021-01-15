class SchoolGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:map]

  def index
    @school_groups = SchoolGroup.order(:name)
  end

  def show
  end

  def map
    @schools = @school_group.schools.visible.order(name: :asc)
    respond_to do |format|
      format.html
      format.json { render json: Maps::Features.new(@schools).as_json, status: :ok }
    end
  end
end
