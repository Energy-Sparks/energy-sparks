module Admin::Geo
  class LiveDataController < AdminController
    DEFAULT_SYSTEM_ID = '99a39901-1ca6-4f3d-8b2d-8ad086290352'.freeze

    def create
      system_id = params[:system_id]
      api = MeterReadingsFeeds::GeoApi.new(username: ENV['GEO_API_USERNAME'], password: ENV['GEO_API_PASSWORD'])
      token = api.login
      api.trigger_fast_update(system_id)
      session[:geo_token] = token
      redirect_to admin_geo_live_data_path(system_id: system_id)
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def show
      @system_id = params[:system_id]
      @token = session[:geo_token]
      if @token && @system_id
        @data = MeterReadingsFeeds::GeoApi.new(token: @token).live_data(@system_id)
      else
        @system_id = DEFAULT_SYSTEM_ID
      end
    end
  end
end
