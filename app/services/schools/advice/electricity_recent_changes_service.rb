module Schools
  module Advice
    class ElectricityRecentChangesService < BaseService
      include AnalysableMixin

      def enough_data?
        meter_data_checker.at_least_x_days_data?(7)
      end

      def data_available_from
        meter_data_checker.date_when_enough_data_available(7)
      end

      def enough_data_for_full_week_comparison?
        start_date = aggregate_meter.amr_data.start_date.sunday? ? aggregate_meter.amr_data.start_date : aggregate_meter.amr_data.start_date.next_occurring(:sunday)
        ((asof_date - start_date) + 1) >= 14
      end

      private

      def asof_date
        @asof_date ||= AggregateSchoolService.analysis_date(@meter_collection, :electricity)
      end

      def aggregate_meter
        @meter_collection.aggregated_electricity_meters
      end

      def meter_data_checker
        @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, asof_date)
      end
    end
  end
end
