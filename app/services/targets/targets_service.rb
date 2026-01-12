# frozen_string_literal: true

# originally from analytics containing target logic, probably should be refactored future
module Targets
  class TargetsService
    include Logging

    def initialize(aggregate_school, fuel_type, period: :year)
      @aggregate_school = aggregate_school
      @fuel_type = set_fuel_type(fuel_type)
      @period = period
    end

    # Called by application to determine if we have enough data for a school to
    # set and calculate a target. Should cover all necessary data
    #
    # We require at least a years worth of calendar data, as well as ~1 year of AMR data OR an estimate of their annual consumption
    def enough_data_to_set_target?
      !fuel_type_disabled? && enough_holidays? && enough_temperature_data? &&
        (enough_readings_to_calculate_target? || enough_estimate_data_to_calculate_target?)
    end

    delegate :enough_holidays?, to: :target_dates

    def default_target_start_date
      TargetDates.default_target_start_date(aggregate_meter)
    end

    # Are there enough historical meter readings to calculate a target?
    # This should be checking whether there’s enough historical data, regardless of
    # whether the data is currently lagging behind (see below). So checking for the
    # oldest data, not the most recent.
    def enough_readings_to_calculate_target?
      return false if aggregate_meter.nil?

      one_year_of_meter_readings_available_prior_to_1st_date?
    end

    # one year of meter readings are required prior to the first target date
    # in order to calculate a target for the following year in the absence
    # of needing to calculate a full year of data synthetically using an 'annual kWh estimate'
    # however, a year after setting the target, the target_start date for calculation purposes
    # will incrementally move at 1 year behind the most recent meter reading date - at this point
    # there may be enough real historic meter readings for a meter which originally has less
    # then 1 year's data to have 1 year of data and not required the 'annual kWh estimate' and
    # therefore the synthetic calculation
    def one_year_of_meter_readings_available_prior_to_1st_date?
      target_dates.one_year_of_meter_readings_available_prior_to_1st_date?
    end

    def can_calculate_one_year_of_synthetic_data?
      TargetDates.can_calculate_one_year_of_synthetic_data?(aggregate_meter)
    end

    def annual_kwh_estimate?
      aggregate_meter.estimated_period_consumption_set?
    end

    def annual_kwh_estimate_required?
      !target_dates.full_years_benchmark_data?
    end

    def enough_temperature_data?
      @fuel_type == :electricity || @aggregate_school.temperatures.days > 365 * 2
    end

    def meter_present?
      aggregate_meter.present?
    end

    private

    # Is there enough data to produce an estimate of historical usage to calculate a target.
    # Checks if the estimate attribute needs to be, and is, set
    # Might also need some minimal readings
    def enough_estimate_data_to_calculate_target?
      annual_kwh_estimate_required? && annual_kwh_estimate? && can_calculate_one_year_of_synthetic_data?
    end

    def target_dates
      TargetDates.new(aggregate_meter, TargetAttributes.new(aggregate_meter))
    end

    def fuel_type_disabled?
      ENV["FEATURE_FLAG_TARGETS_DISABLE_#{@fuel_type.to_s.upcase}"] == 'true'
    end

    def aggregate_meter
      @aggregate_meter ||= @aggregate_school.aggregate_meter(@fuel_type)
    end

    def set_fuel_type(fuel_type)
      fuel_type == :storage_heaters ? :storage_heater : fuel_type
    end
  end
end
