module Schools
  module Advice
    class ElectricityRecentChangesService < BaseService
      include AnalysableMixin

      def enough_data?
        meter_data_checker.at_least_x_days_data?(14)
      end

      #Not yet implemented in underlying services
      def data_available_from
        meter_data_checker.date_when_enough_data_available(14)
      end

      def asof_date
        @asof_date ||= AggregateSchoolService.analysis_date(@meter_collection, :electricity)
      end

      private

      def aggregate_meter
        @meter_collection.aggregated_electricity_meters
      end

      def meter_data_checker
        @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, asof_date)
      end
    end
  end
end
