module Schools
  module AdvicePageBenchmarks
    class BaseloadBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return nil unless baseload_service.enough_data?
        comparison = baseload_service.benchmark_baseload
        return comparison.category
      end

      private

      def baseload_service
        @baseload_service ||= Schools::Advice::BaseloadService.new(@school, @aggregate_school)
      end
    end
  end
end
