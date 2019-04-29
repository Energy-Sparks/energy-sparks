module Schools
  class AggregatedMeterCollectionController < ApplicationController
    before_action :set_school


    def show
      @number_of_meter_readings = 1_000_000
      @number_of_weather_readings = 1_000
      @number_of_solar_pv_readings = 1_000
    end

    def post
      # JSON request to load cache
      ass = AggregateSchoolService.new(@school)
      ass.aggregate_school unless ass.in_cache?

      head :no_content
    end

    def set_school
      @school = School.friendly.find(params[:school_id])
    end
  end
end
