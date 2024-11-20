class MapController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    schools = School.visible
    schools = schools.where(school_group_id: params[:school_group_id]) if params[:school_group_id]
    render json: Maps::SchoolFeatures.new(schools).as_json, status: :ok
  end

  def popup
    raise ActionController::RoutingError.new('Not Found') unless params[:id].present?
    @school = School.find(params[:id])
    render :popup, layout: false
  end
end
