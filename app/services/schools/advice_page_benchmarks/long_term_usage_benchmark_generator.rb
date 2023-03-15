module Schools
  module AdvicePageBenchmarks
    class LongTermUsageBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless usage_service.enough_data?
        usage_service.benchmark_usage.category
      end

      private

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, @aggregate_school, advice_page_fuel_type)
      end
    end
  end
end
