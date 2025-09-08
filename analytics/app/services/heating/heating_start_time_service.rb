# frozen_string_literal: true

require 'ostruct'

module Heating
  class HeatingStartTimeService < BaseService
    # Create a service capable of calculating a breakdown of the heating
    # start times for a give date range
    #
    # @param [MeterCollection] meter_collection the school to be analysed
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if the schools doesnt have gas meters
    # @raise [EnergySparksUnexpectedStateException] if the school does not use gas for heating
    def initialize(meter_collection, asof_date = Date.today)
      validate_meter_collection(meter_collection)
      super(meter_collection, asof_date)
    end

    def enough_data?
      meter_date_range_checker.at_least_x_days_data?(ONE_WEEK) && super
    end

    # Find the average start time over the last week
    def average_start_time_last_week
      _days, _rating, average_heat_start_time = calculate_start_times
      average_heat_start_time
    end

    # Returns details about the heating start times over the last week
    #
    # @return [HeatingStartTimes] the heating start times over the last week
    def last_week_start_times
      days, _rating_percent, average_start_time = calculate_start_times

      days = days.map do |day|
        # unpack the array
        date, heating_start_time, recommended_time, temperature, _timing, kwh_saving, saving_£, saving_co2 = day
        OpenStruct.new(
          date: date,
          heating_start_time: heating_start_time,
          recommended_time: recommended_time,
          temperature: temperature,
          saving: CombinedUsageMetric.new(kwh: kwh_saving, £: saving_£, co2: saving_co2)
        )
      end
      HeatingStartTimes.new(days: days, average_start_time: average_start_time)
    end

    private

    def calculate_start_times
      # [days_assessment, overall_rating_percent, average_heat_start_time]
      # [date, heating_on_time, recommended_time, temperature, timing, kwh_saving, saving_£, saving_co2]
      @heating_start_times = heating_start_time_calculator.calculate_start_times(@asof_date)
    end

    def heating_start_time_calculator
      @heating_start_time_calculator ||= HeatingStartTimeCalculator.new(heating_model: heating_model)
    end
  end
end
