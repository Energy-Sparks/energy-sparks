module Schools
  module Advice
    class ThermostaticAnalysisService
      include AnalysableMixin

      def initialize(school, meter_collection)
        @school = school
        @meter_collection = meter_collection
      end

      def enough_data?
        thermostatic_analysis_service.enough_data?
      end

      def data_available_from
        thermostatic_analysis_service.data_available_from
      end

      def thermostatic_analysis
        build_thermostatic_analysis_model
      end

      #Benchmark schools using their r2 value.
      #See HeatingModel.r2_statistics for an example of grading r2 values
      def benchmark_thermostatic_control
        Schools::Comparison.new(
          school_value: thermostatic_analysis.r2,
          benchmark_value: 0.6,
          exemplar_value: 0.8,
          unit: :r2,
          low_is_good: false
        )
      end

      private


      def build_thermostatic_analysis_model
        thermostatic_analysis_service.create_model
      end

      def thermostatic_analysis_service
        @thermostatic_analysis_service ||= Heating::HeatingThermostaticAnalysisService.new(meter_collection: @meter_collection)
      end
    end
  end
end
