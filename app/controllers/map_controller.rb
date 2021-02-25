class MapController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    schools = School.visible.order(:name)
    schools = schools.where(school_group_id: params[:school_group_id]).order(:name) if params[:school_group_id]
    render json: Maps::SchoolFeatures.new(schools).as_json, status: :ok
  end
end
