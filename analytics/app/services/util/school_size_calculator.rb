# frozen_string_literal: true

module Util
  # For a given school, meter and date range calculate the number of pupils
  # and floor area covered by the meter
  #
  # This calculation takes into account not just the fixed values for pupils counts
  # and floor areas associated with schools, it will also process the custom
  # meter attributes that allow historical changes in school size to be described, as well
  # as partial meter coverage. Although these are not yet in use.
  class SchoolSizeCalculator
    def initialize(meter_collection, analytics_meter, start_date = nil, end_date = nil)
      @meter_collection = meter_collection
      @meter = analytics_meter
      @start_date = start_date
      @end_date = end_date
    end

    def pupils
      @pupils ||= @meter.meter_number_of_pupils(@meter_collection, @start_date, @end_date)
    end

    def floor_area
      @floor_area ||= @meter.meter_floor_area(@meter_collection, @start_date, @end_date)
    end
  end
end
