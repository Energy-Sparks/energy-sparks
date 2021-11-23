module SchoolAggregation
  extend ActiveSupport::Concern

private

  def check_aggregated_school_in_cache
    return unless show_data_enabled_features?
    unless aggregate_school_service.in_cache_or_cache_off? || request.xhr?
      setup_loading_stats
      @aggregation_path = school_aggregated_meter_collection_path(@school)
      render 'schools/aggregated_meter_collections/show'
    end
  end

  def show_data_enabled_features?
    if current_user && current_user.admin?
      params[:no_data] ? false : true
    else
      @school.data_enabled?
    end
  end

  def setup_loading_stats
    @number_of_meter_readings = @school.amr_validated_readings.count * 48
    @number_of_meters = @school.meters.count
    @number_of_weather_readings = number_of_weather_readings
    @number_of_solar_pv_readings = number_of_solar_readings
  end

  def aggregate_school_service
    @aggregate_school_service ||= AggregateSchoolService.new(@school)
  end

  def aggregate_school
    aggregate_school_service.aggregate_school
  end

  def number_of_solar_readings
    if @school.solar_pv_tuos_area.present?
      DataFeeds::SolarPvTuosReading.where(area_id: @school.solar_pv_tuos_area.id).count * 48
    end
    0
  end

  def number_of_weather_readings
    if @school.weather_station.present?
      WeatherObservation.where(weather_station_id: @school.weather_station.id).count * 48
    elsif @school.dark_sky_area.present?
      DataFeeds::DarkSkyTemperatureReading.where(area_id: @school.dark_sky_area.id).count * 48
    else
      0
    end
  end
end
