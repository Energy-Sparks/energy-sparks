module SchoolAggregation
  extend ActiveSupport::Concern

  included do
    before_action :check_aggregated_school_in_cache, unless: proc {|_c| request.xhr? }
  end

private

  def check_aggregated_school_in_cache
    unless aggregate_school_service.in_cache_or_cache_off?
      setup_loading_stats
      @aggregation_path = school_aggregated_meter_collection_path(@school)
      render 'schools/aggregated_meter_collections/show'
    end
  end

  def setup_loading_stats
    @number_of_meter_readings = @school.amr_validated_readings.count * 48
    @number_of_meters = @school.meters.count

    data_feed = @school.weather_underground_area.data_feed
    @number_of_weather_readings = DataFeedReading.where(data_feed: data_feed, feed_type: :temperature).count
    @number_of_solar_pv_readings = DataFeeds::SolarPvTuosReading.where(area_id: @school.solar_pv_tuos_area.id).count * 48
  end

  def aggregate_school_service
    @aggregate_school_service ||= AggregateSchoolService.new(@school)
  end

  def aggregate_school
    aggregate_school_service.aggregate_school
  end
end
