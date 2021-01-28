module Admin
  class WeatherStationsController < AdminController
    load_and_authorize_resource

    def index
    end

    def new
    end

    def create
      if @weather_station.save
        redirect_to admin_weather_stations_path, notice: 'New Weather Station created.'
      else
        render :new
      end
    end

    def edit
    end

    #TODO decide how to handle lat/lng updates, if at all
    def update
      if @weather_station.update(weather_station_params)
        redirect_to admin_weather_stations_path, notice: 'Weather Station was updated.'
      else
        render :edit
      end
    end

    private

    def weather_station_params
      params.require(:weather_station).permit(:title, :description, :type, :latitude, :longitude, :active, :provider, :back_fill_years)
    end
  end
end
