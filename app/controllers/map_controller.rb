class MapController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    schools = School.visible
    schools = schools.where(school_group_id: params[:school_group_id]) if params[:school_group_id]
    render json: Maps::Features.new(schools).as_json, status: :ok
  end
end
