module Schools
  module AdvicePageBenchmarks
    class PeakUsageBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless usage_service.enough_data?
        usage_service.benchmark_peak_usage.category
      end

      private

      def usage_service
        @usage_service ||= Schools::Advice::PeakUsageService.new(@school, aggregate_school_service)
      end
    end
  end
end
