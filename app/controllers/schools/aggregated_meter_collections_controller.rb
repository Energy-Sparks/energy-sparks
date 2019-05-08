module Schools
  class AggregatedMeterCollectionsController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!, only: [:show, :post]

    def show
      @number_of_meter_readings = @school.amr_validated_readings.count * 48
      @number_of_meters = @school.meters.count

      data_feed = @school.weather_underground_area.data_feed
      @number_of_weather_readings = DataFeedReading.where(data_feed: data_feed, feed_type: :temperature).count

      data_feed = @school.solar_pv_tuos_area.data_feed
      @number_of_solar_pv_readings = DataFeedReading.where(data_feed: data_feed).count
    end

    def post
      # JSON request to load cache
      ass = AggregateSchoolService.new(@school)
      ass.aggregate_school unless ass.in_cache?

      next_page = session[:aggregated_meter_collection_referrer] || school_path(@school)

      respond_to do |format|
        format.json { render json: { referrer: next_page }}
      end
    end
  end
end
