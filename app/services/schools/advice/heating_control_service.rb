module Schools
  module Advice
    class HeatingControlService
      include AnalysableMixin

      def initialize(school, meter_collection)
        @school = school
        @meter_collection = meter_collection
      end

      def enough_data?
        heating_start_time_service.enough_data?
      end

      #TODO: needs changes in the analytics
      def data_available_from
        nil
      end

      def average_start_time_last_week
        heating_start_time_service.average_start_time_last_week
      end

      def last_week_start_times
        heating_start_time_service.last_week_start_times
      end

      def percentage_of_annual_gas
        heating_savings_service.percentage_of_annual_gas
      end

      def estimated_savings
        heating_savings_service.estimated_savings
      end

      def seasonal_analysis
        seasonal_analysis_service.seasonal_analysis
      end

      def enough_data_for_seasonal_analysis?
        seasonal_analysis_service.enough_data?
      end

      private

      def heating_start_time_service
        @heating_start_time_service ||= Heating::HeatingStartTimeService.new(@meter_collection, analysis_date)
      end

      def heating_savings_service
        @heating_savings_service ||= Heating::HeatingStartTimeSavingsService.new(@meter_collection, analysis_date)
      end

      def seasonal_analysis_service
        @seasonal_analysis_service ||= Heating::SeasonalControlAnalysisService.new(meter_collection: @meter_collection)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(@meter_collection, :gas)
      end
    end
  end
end
