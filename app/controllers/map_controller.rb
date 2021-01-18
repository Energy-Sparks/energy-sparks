class MapController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    gon.OSDATAHUB_API_KEY = ENV['OSDATAHUB_API_KEY']
    gon.MAPBOX_API_KEY = ENV['MAPBOX_API_KEY']

    @schools = School.visible.order(name: :asc)
    @school_groups = SchoolGroup.all.order(name: :asc)
    respond_to do |format|
      format.html
      format.json { render json: Maps::Features.new(@schools).as_json, status: :ok }
    end
  end
end
