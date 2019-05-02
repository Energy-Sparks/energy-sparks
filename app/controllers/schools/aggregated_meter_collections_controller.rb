module Schools
  class AggregatedMeterCollectionsController < ApplicationController
    before_action :set_school

    def show
      @number_of_meter_readings = @school.amr_validated_readings.count * 48
      @number_of_meters = @school.meters.count

      data_feed = DataFeed.where(area: @school.weather_underground_area).first
      @number_of_weather_readings = DataFeedReading.where(data_feed: data_feed, feed_type: :temperature).count

      data_feed = DataFeed.where(area: @school.solar_pv_tuos_area).first
      @number_of_solar_pv_readings = DataFeedReading.where(data_feed: data_feed).count
    end

    def post
      # JSON request to load cache
      ass = AggregateSchoolService.new(@school)
      ass.aggregate_school unless ass.in_cache?

      respond_to do |format|
        format.json { render json: { referrer: session[:aggregated_meter_collection_referrer] }}
      end
    end

    def set_school
      @school = School.friendly.find(params[:school_id])
    end
  end
end
