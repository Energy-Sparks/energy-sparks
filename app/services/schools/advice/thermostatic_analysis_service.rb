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
