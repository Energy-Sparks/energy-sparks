module DataFeeds
  class WeatherObservationsController < GenericController
    load_and_authorize_resource

    def show
      @weather_station = WeatherStation.find(params[:weather_station_id])
      ordered_readings = @weather_station.weather_observations.by_date

      @first_reading = ordered_readings.first
      @reading_summary = ordered_readings.group(:reading_date, :temperature_celsius_x48).pluck(Arel.sql('reading_date, (select avg(n) from unnest(temperature_celsius_x48) n)')).to_h

      respond_to do |format|
        format.html { render 'data_feeds/generic/show_temperatures' }
        format.json { render 'data_feeds/generic/show_temperatures' }
        format.csv  { send_data CsvDownloader.readings_to_csv(WeatherObservation.download_for_area_id(@weather_station.id), WeatherObservation::CSV_HEADER), filename: "#{@weather_station.id}-readings.csv" }
      end
    end
  end
end
