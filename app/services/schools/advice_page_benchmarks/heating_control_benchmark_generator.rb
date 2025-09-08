module Schools
  module AdvicePageBenchmarks
    class HeatingControlBenchmarkGenerator < SchoolBenchmarkGenerator
      def benchmark_school
        return unless heating_control_service.enough_data_for_seasonal_analysis?
        heating_control_service.benchmark_warm_weather_days.category
      end

      private

      def heating_control_service
        @heating_control_service ||= Schools::Advice::HeatingControlService.new(@school, aggregate_school_service)
      end
    end
  end
end
