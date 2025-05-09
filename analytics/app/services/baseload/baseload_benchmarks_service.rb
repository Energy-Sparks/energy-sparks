# frozen_string_literal: true

module Baseload
  class BaseloadBenchmarkingService < BaseService
    include AnalysableMixin

    HOURS_IN_YEAR = (24.0 * 365.0)

    # Create a service capable of producing benchmark comparisons for a
    # given school, based on the data and configuration in their meter
    # collection
    #
    # @param [MeterCollection] meter_collection the school to be benchmarked
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if the schools doesnt have electricity meters
    def initialize(meter_collection, asof_date = Date.today)
      super()
      validate_meter_collection(meter_collection)
      @meter_collection = meter_collection
      # baseload analysis always uses the aggregated meter
      @meter = aggregate_meter
      @asof_date = asof_date
    end

    def enough_data?
      range_checker.at_least_x_days_data?(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    def data_available_from
      enough_data? ? nil : range_checker.date_when_enough_data_available(DEFAULT_DAYS_OF_DATA_REQUIRED)
    end

    # Calculate the expected average annual baseload for a "benchmark"
    # school of the same type and with a similar number of pupils.
    #
    # E.g. calculate the baseload for a well performing primary school, or
    # an exemplar secondary school.
    #
    # Details of school type and number of pupils are taken from the meter collection
    #
    # Supported comparisons are: :benchmark_school, or :exemplar_school
    #
    # @param [Symbol] for the type of benchmark school to be used as comparison
    def average_baseload_kw(compare: :benchmark_school)
      pupils = pupils(@asof_date - 365, @asof_date)
      case compare
      when :benchmark_school
        BenchmarkMetrics.recommended_baseload_for_pupils(pupils, school_type)
      when :exemplar_school
        BenchmarkMetrics.exemplar_baseload_for_pupils(pupils, school_type)
      else
        raise 'Invalid comparison'
      end
    end

    # Calculate the expected usage for a "benchmark" school of the
    # same type and with a similar number of pupils, over a year
    #
    # Supported comparisons are: :benchmark_school, or :exemplar_school
    #
    # The usage returns include kwh, co2 emissions and £ costs.
    # @param [Symbol] for the type of benchmark school to be used as comparison
    # @return [CombinedUsageMetric] the calculated usage
    def baseload_usage(compare: :benchmark_school)
      benchmarked_by_pupil_kw = average_baseload_kw(compare: compare)
      by_pupil_kwh = benchmarked_by_pupil_kw * HOURS_IN_YEAR
      CombinedUsageMetric.new(
        kwh: by_pupil_kwh,
        £: by_pupil_kwh * latest_electricity_tariff,
        co2: by_pupil_kwh * co2_per_kwh
      )
    end

    # Compare the expected annual usage for this school against a benchmark
    # school of the given type.
    #
    # E.g. if this school moved its baseload to match an exemplar, how much
    # would its electricity usage reduce, how much would they save, etc.
    #
    # Returns the expected estimated savings kwh, cost or co2 savings.
    #
    # @param [Symbol] for the type of benchmark school to be used as comparison
    # @return [CombinedUsageMetric] the estimated savings
    def estimated_savings(versus: :benchmark_school)
      average_baseload_last_year_kwh = baseload_calculator.annual_baseload_usage.kwh

      baseload_usage_for_comparison = baseload_usage(compare: versus)

      one_year_saving_versus_comparison_kwh = average_baseload_last_year_kwh - baseload_usage_for_comparison.kwh

      CombinedUsageMetric.new(
        kwh: one_year_saving_versus_comparison_kwh,
        £: one_year_saving_versus_comparison_kwh * latest_electricity_tariff,
        co2: one_year_saving_versus_comparison_kwh * co2_per_kwh
      )
    end

    private

    def latest_electricity_tariff
      @latest_electricity_tariff ||= baseload_analysis.blended_baseload_tariff_rate_£_per_kwh(:£current, @asof_date)
    end

    def school_type
      @meter_collection.school_type
    end

    def aggregate_meter
      @meter_collection.aggregated_electricity_meters
    end

    def pupils(start_date = nil, end_date = nil)
      aggregate_meter.meter_number_of_pupils(@meter_collection, start_date, end_date)
    end

    def baseload_calculator
      @baseload_calculator ||= BaseloadCalculationService.new(@meter, @asof_date)
    end

    def range_checker
      meter_date_range_checker(@meter, @asof_date)
    end
  end
end
