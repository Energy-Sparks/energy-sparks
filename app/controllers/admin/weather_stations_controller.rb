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

    def update
      if @weather_station.update(weather_station_params)
        @weather_station.weather_observations.delete_all if lat_long_changed?
        redirect_to admin_weather_stations_path, notice: 'Weather Station was updated.'
      else
        render :edit
      end
    end

    private

    def lat_long_changed?
      changes = @weather_station.previous_changes
      changes.key?(:latitude) || changes.key?(:longitude)
    end

    def weather_station_params
      params.require(:weather_station).permit(:title, :description, :type, :latitude, :longitude, :active, :provider, :back_fill_years)
    end
  end
end
