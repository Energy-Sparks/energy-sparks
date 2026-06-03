module Schools
  module AdvicePageBenchmarks
    class BaseloadBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless baseload_service.enough_data?
        baseload_service.benchmark_baseload.category
      end

      private

      def baseload_service
        @baseload_service ||= Schools::Advice::BaseloadService.new(@school, aggregate_school_service)
      end
    end
  end
end
