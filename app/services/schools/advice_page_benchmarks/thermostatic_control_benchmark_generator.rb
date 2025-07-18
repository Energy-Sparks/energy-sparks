module Schools
  module AdvicePageBenchmarks
    class ThermostaticControlBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless thermostatic_analysis_service.enough_data?
        thermostatic_analysis_service.benchmark_thermostatic_control.category
      end

      private

      def thermostatic_analysis_service
        @thermostatic_analysis_service ||= Schools::Advice::ThermostaticAnalysisService.new(@school, aggregate_school_service)
      end
    end
  end
end
