module DataFeeds
  class WeatherObservationsController < GenericController
    include CsvDownloader

    load_and_authorize_resource

    CSV_HEADER = 'Area Title,Reading Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

    def show
      weather_station_id = params[:weather_station_id]
      ordered_readings = @data_class.where(weather_station_id: weather_station_id).order(reading_date: :asc)

      @first_read = ordered_readings.first
      @reading_summary = ordered_readings.group(:reading_date, @data_class_column_name).pluck(Arel.sql("reading_date, array_length(#{@data_class_column_name}, 1)")).to_h
      @missing_array = get_missing_array(@first_read, @reading_summary)

      respond_to do |format|
        format.html { render 'data_feeds/generic/show' }
        format.json { render 'data_feeds/generic/show' }
        format.csv  { send_data readings_to_csv(@data_class.download_for_area_id(weather_station_id), @csv_header), filename: "#{weather_station_id}-#{@title}.csv" }
      end
    end

    def set_up_data_feed
      @title = 'Weather station readings'.freeze
      @data_class = WeatherObservation
      @data_class_column_name = :temperature_celsius_x48
      @csv_header = CSV_HEADER
    end
  end
end
