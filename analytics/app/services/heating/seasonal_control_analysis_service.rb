# frozen_string_literal: true

module Heating
  # Service to carry out seasonal analysis of a school's heating
  #
  # This is interface currently only exposes the analysis of when heating is
  # on during warm weather.
  #
  # The analysis requires at least 12 months of data to in order to fit a model
  # to the schools's data. The analysis is then carried out on the most recent
  # 12 months of data.
  class SeasonalControlAnalysisService < BaseService
    def initialize(meter_collection:, fuel_type: :gas)
      raise 'Invalid fuel type' unless %i[gas storage_heater].include? fuel_type

      validate_meter_collection(meter_collection)
      super(meter_collection, nil, fuel_type)
    end

    def enough_data?
      meter_date_range_checker.one_years_data? && super
    end

    def data_available_from
      enough_data? ? nil : meter_date_range_checker.date_when_one_years_data
    end

    def seasonal_analysis
      # hash of {kwh:, £:, £current, co2: days:, degree_days:}
      analysis = heating_on_warm_weather_total_consumption
      # return £current values as we are projecting future savings
      OpenStruct.new(
        heating_on_in_warm_weather_days: analysis[:days],
        percent_of_annual_heating: percent_of_annual_heating,
        estimated_savings: CombinedUsageMetric.new(
          kwh: analysis[:kwh],
          £: analysis[:£current],
          co2: analysis[:co2]
        )
      )
    end

    private

    # Adds up the kwh, £, co2, days, etc values across all time periods
    # this produces an annual total of cost, consumption, etc when heating is
    # on during warm weather
    #
    # The result is equivalent to the warm_weather_heating_days_all_days_* variables
    # calculated by the AlertSeasonalHeatingSchoolDays
    def heating_on_warm_weather_total_consumption
      sum_over_values(heating_on_warm_weather_values)
    end

    def heating_on_cold_weather_total_consumption
      sum_over_values(heating_on_cold_weather_values)
    end

    def percent_of_annual_heating
      percent(heating_on_warm_weather_total_consumption[:kwh], heating_on_cold_and_warm_weather_total_kwh)
    end

    # Total kwh consumption across cold and warm weather days
    def heating_on_cold_and_warm_weather_total_kwh
      heating_on_warm_weather_total_consumption[:kwh] +
        heating_on_cold_weather_total_consumption[:kwh]
    end

    # Return consumption data for warm weather
    def heating_on_warm_weather_values
      extract_values_from_seasonal_analysis(:heating_warm_weather)
    end

    # Return consumption data for cold weather
    def heating_on_cold_weather_values
      extract_values_from_seasonal_analysis(:heating_cold_weather)
    end

    def percent(v1, v2)
      return nil if v1.nil? || v2.nil? || v2 == 0.0

      v1 / v2
    end

    def sum_over_values(values)
      # Returns a single hash with summed values of matching keys in an array of hashes e.g.
      # an array of hashes such as [{kwh: 12}, {kwh: 6}] will return a hash {kwh: 18}
      result = Hash.new(0)
      values.each do |subhash|
        subhash.each do |type, value|
          result[type] += value
        end
      end
      result
    end

    # Extract the data for a specific category of usage (e.g. :heating_warm_weather, :heating_cold_weather)
    # from across the different time periods returned by the analysis.
    #
    # Returns an array of hashes with kwh, £, £current, co2, days, and degree days values
    def extract_values_from_seasonal_analysis(category)
      heating_on_seasonal_analysis.values.map { |period| period[category] }.compact
    end

    # carry out the seasonal analysis using the default date ranges:
    # start_date = one year ago
    # end_date = latest date for aggregate meter
    #
    # returns a hash with keys for :schoolday, :weekend, :holiday
    # the values are hashes of period, e.g. :heating_cold_weather, :heating_warm_weather
    # to kwh, £, co2, 15, etc, savings
    def heating_on_seasonal_analysis
      @heating_on_seasonal_analysis ||= heating_model.heating_on_seasonal_analysis
    end

    def heating_model
      @heating_model ||= calculate_heating_model
    end

    def amr_start_date
      aggregate_meter.amr_data.start_date
    end

    def amr_end_date
      aggregate_meter.amr_data.end_date
    end

    def calculate_heating_model
      # The period could be alerted here to parameterise the analysis based on date
      period_start_date = [amr_end_date - 365, amr_start_date].max
      last_year = SchoolDatePeriod.new(:analysis, 'seasonal analysis', period_start_date, amr_end_date)
      aggregate_meter.heating_model(last_year)
    end
  end
end
