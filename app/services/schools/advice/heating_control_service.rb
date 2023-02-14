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

      private

      def heating_start_time_service
        puts analysis_date.inspect
        @heating_start_time_service ||= Heating::HeatingStartTimeService.new(@meter_collection, analysis_date)
      end

      def heating_savings_service
        @heating_savings_service ||= Heating::HeatingStartTimeSavingsService.new(@meter_collection, analysis_date)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(@meter_collection, :gas)
      end
    end
  end
end
