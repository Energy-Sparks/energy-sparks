# frozen_string_literal: true

module Util
  # Simple utility class for checking the amount of data available for a
  # meter
  class MeterDateRangeChecker
    RECENT_DATA_DAYS = 30

    # Specifying a nil asof_date means the checks will be done against the
    # latest date for which we have data for this meter.
    #
    # If the date to be checked is later than the latest data, then checks will
    # be done against that date
    #
    # @param [Dashboard::Meter] analytics_meter the meter to be checked
    # @param [Date] asof_date the date to use as the basis for calculations
    # @param [Integer] days_in_year we sometimes treat a year as 364 days, allow override
    def initialize(analytics_meter, asof_date = Date.today, days_in_year: 365)
      @meter = analytics_meter
      @asof_date = asof_date.nil? ? @meter.amr_data.end_date : [@meter.amr_data.end_date, asof_date].min
      @days_in_year = days_in_year
    end

    def one_years_data?
      at_least_x_days_data?(@days_in_year)
    end

    def two_years_data?
      at_least_x_days_data?(@days_in_year * 2)
    end

    def at_least_x_days_data?(days)
      days_of_data >= days
    end

    # How many days of data do we have between the date we're checking and the start data of the meter
    def days_of_data
      (@asof_date - @meter.amr_data.start_date) + 1
    end

    # Do we have recent data for the meter?
    def recent_data?
      days_data_is_lagging < RECENT_DATA_DAYS
    end

    # Return the number of days between today (the current date) and
    # the last date for which we have data for this meter
    #
    # Always checks against the current date, not the asof_date provided
    # in the constructor
    def days_data_is_lagging
      Date.today - @meter.amr_data.end_date
    end

    # At what date will we have one years data
    def date_when_one_years_data
      date_when_enough_data_available(@days_in_year)
    end

    # At what date will we have two years of data
    def date_when_two_years_data
      date_when_enough_data_available(@days_in_year * 2)
    end

    # Estimate when we will have enough data available
    def date_when_enough_data_available(days_required)
      return nil if days_of_data >= days_required

      extra_days_needed = days_required - days_of_data
      @asof_date + extra_days_needed
    end
  end
end
