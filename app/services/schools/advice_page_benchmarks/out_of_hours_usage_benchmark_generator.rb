module Schools
  module AdvicePageBenchmarks
    class OutOfHoursUsageBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless usage_service.enough_data?
        benchmark_usage.category
      end

      private

      def benchmark_usage
        annual_out_of_hours_kwh = usage_service.annual_out_of_hours_kwh
        Schools::Comparison.new(
          school_value: annual_out_of_hours_kwh[:out_of_hours],
          benchmark_value: (annual_out_of_hours_kwh[:total_annual] * BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY),
          exemplar_value: (annual_out_of_hours_kwh[:total_annual] * BenchmarkMetrics::EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY),
          unit: :kwh
        )
      end

      def usage_service
        @usage_service ||= ::Usage::AnnualUsageBreakdownService.new(
          meter_collection: @aggregate_school,
          fuel_type: advice_page_fuel_type
        )
      end
    end
  end
end
