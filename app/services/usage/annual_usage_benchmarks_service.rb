# frozen_string_literal: true

module Usage
  class AnnualUsageBenchmarksService
    include AnalysableMixin

    DAYSINYEAR = 363

    # Create a service capable of producing annual usage benchmark comparisons for a
    # given school, based on the data for an aggregate meter
    #
    # @param [MeterCollection] meter_collection the school to be benchmarked
    # @param fuel_type the fuel type to be assessed, e.g. +:gas+ or +:electricity+
    # @param [Date] asof_date the date to use as the basis for calculations
    #
    # @raise [EnergySparksUnexpectedStateException] if the schools doesnt have electricity meters
    def initialize(meter_collection, fuel_type, asof_date = Date.current)
      validate_meter_collection(meter_collection, fuel_type)
      @meter_collection = meter_collection
      @fuel_type = fuel_type
      @asof_date = asof_date
    end

    # Do we have enough data to run the calculations?
    def enough_data?
      meter_data_checker.one_years_data?
    end

    # If we don't have enough data, then when will it be available?
    def data_available_from
      meter_data_checker.date_when_enough_data_available(365)
    end

    # Calculate the annual electricity usage for a benchmark school of the
    # specified type, with a similar number of pupils
    def annual_usage_kwh(compare: :benchmark_school)
      case compare
      when :benchmark_school
        @fuel_type == :electricity ? benchmark_annual_electricity_usage_kwh : benchmark_annual_gas_usage_kwh
      when :exemplar_school
        @fuel_type == :electricity ? exemplar_annual_electricity_usage_kwh : exemplar_annual_gas_usage_kwh
      else
        raise 'Invalid comparison'
      end
    end

    # Calculate the expected annual usage for a "benchmark" school of the
    # same type and with a similar number of pupils, over a year
    #
    # Supported comparisons are: :benchmark_school, or :exemplar_school
    #
    # @param [Symbol] for the type of benchmark school to be used as comparison
    # @return [CombinedUsageMetric] the estimated usage
    def annual_usage(compare: :benchmark_school)
      benchmarked_by_pupil_kwh = annual_usage_kwh(compare: compare)

      # we're estimating future savings, so use £current
      benchmark_by_pupil_gbp_current = benchmarked_by_pupil_kwh * current_blended_rate_gbp_per_kwh

      # NOTE: the current alert doesn't currently calculate co2 estimates, except for
      # savings versus exemplar, but adding this in for completeness. Uses same method as
      # for estimating co2 usage in baseload benchmarking, and for calculating savings vs exemplar
      # for annual usage
      benchmark_by_pupil_co2 = benchmarked_by_pupil_kwh * co2_per_kwh

      CombinedUsageMetric.new(
        kwh: benchmarked_by_pupil_kwh,
        gbp: benchmark_by_pupil_gbp_current,
        co2: benchmark_by_pupil_co2
      )
    end

    # Compare the annual usage for this school against a benchmark
    # school of the given type to estimate potential savings
    #
    # Returns the expected estimated savings kwh, cost or co2 savings. The
    # returned metric also includes the % difference between the kwh consumed
    # by the benchmark vs actual school.
    #
    # @param [Symbol] for the type of benchmark school to be used as comparison
    # @return [CombinedUsageMetric] the estimated savings
    def estimated_savings(versus: :benchmark_school)
      # calculate kwh used last year for the school
      last_year_kwh = usage_calculator.usage(period: :this_year).kwh

      # calculate usage for this type of benchmark school
      annual_usage_for_comparison = annual_usage(compare: versus)
      saving_versus_benchmark_kwh = last_year_kwh - annual_usage_for_comparison.kwh

      # Use £current as these are future savings
      saving_versus_benchmark_gbp = saving_versus_benchmark_kwh * current_blended_rate_gbp_per_kwh
      saving_versus_benchmark_co2 = saving_versus_benchmark_kwh * co2_per_kwh

      CombinedUsageMetric.new(
        kwh: saving_versus_benchmark_kwh.magnitude,
        gbp: saving_versus_benchmark_gbp.magnitude,
        co2: saving_versus_benchmark_co2.magnitude,
        percent: percent_change(annual_usage_for_comparison.kwh, last_year_kwh)
      )
    end

    private

    def benchmark_annual_electricity_usage_kwh
      BenchmarkMetrics.benchmark_annual_electricity_usage_kwh(school_type, school_size_calculator.pupils)
    end

    def exemplar_annual_electricity_usage_kwh
      BenchmarkMetrics.exemplar_annual_electricity_usage_kwh(school_type, school_size_calculator.pupils)
    end

    def benchmark_annual_gas_usage_kwh
      BenchmarkMetrics::BENCHMARK_GAS_USAGE_PER_M2 * school_size_calculator.floor_area / degree_day_adjustment
    end

    def exemplar_annual_gas_usage_kwh
      BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2 * school_size_calculator.floor_area / degree_day_adjustment
    end

    def degree_day_adjustment
      BenchmarkMetrics.normalise_degree_days(@meter_collection.temperatures, @meter_collection.holidays, :gas, @asof_date)
    end

    def percent_change(old_value, new_value)
      return nil if old_value.nil? || new_value.nil?
      return 0.0 if !old_value.nan? && old_value == new_value # both 0.0 case

      (new_value - old_value) / old_value
    end

    # Taken from content_base.rb
    def current_blended_rate_gbp_per_kwh
      aggregate_meter.amr_data.current_tariff_rate_gbp_per_kwh
    end

    # Calculate the co2 per kwh rate for this school, to convert kwh values
    # into co2 emissions
    def co2_per_kwh
      rate_calculator.blended_co2_per_kwh
    end

    def school_type
      @meter_collection.school_type
    end

    def aggregate_meter
      @meter_collection.aggregate_meter(@fuel_type)
    end

    def usage_calculator
      @usage_calculator ||= CalculationService.new(aggregate_meter, @asof_date)
    end

    def school_size_calculator
      @school_size_calculator ||= Util::SchoolSizeCalculator.new(@meter_collection, aggregate_meter, @asof_date - DAYSINYEAR, @asof_date)
    end

    def rate_calculator
      @rate_calculator ||= Costs::BlendedRateCalculator.new(aggregate_meter)
    end

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, @asof_date)
    end

    def validate_meter_collection(meter_collection, fuel_type)
      raise EnergySparksUnexpectedStateException, 'School does not have this fuel type' if meter_collection.aggregate_meter(fuel_type).nil?
    end
  end
end
