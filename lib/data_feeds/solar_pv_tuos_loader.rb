module DataFeeds
  class SolarPvTuosLoader
    # This will actually fire up and get the data
    # Default start and end dates can be removed once all working
    def initialize(start_date = Date.new(2018, 4, 13), end_date = Date.new(2018, 4, 14))
      @start_date = start_date
      @end_date = end_date
      @method = :weighted_average
      @max_temperature = 38.0
      @min_temperature = -15.0
      @max_minutes_between_samples = 120
      @max_solar_onsolence = 2000.0
      @csv_format = :portrait
    end

    def import
      pp "No action yet"
    end
  end
end
