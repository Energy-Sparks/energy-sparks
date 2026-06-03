module Schools
  module AdvicePageBenchmarks
    class LongTermUsageBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless enough_data?
        usage_service.benchmark_usage.category
      end

      private

      def enough_data?
        Util::MeterDateRangeChecker.new(@aggregate_school.aggregate_meter(advice_page_fuel_type)).one_years_data?
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school_service, advice_page_fuel_type)
      end
    end
  end
end
