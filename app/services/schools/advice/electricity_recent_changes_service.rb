module Schools
  module Advice
    class ElectricityRecentChangesService < BaseService
      include AnalysableMixin

      def enough_data?
        meter_data_checker.at_least_x_days_data?(14)
      end

      def data_available_from
        meter_data_checker.date_when_enough_data_available(14)
      end

      def date_ranges
        last_week_end_date = aggregate_meter.amr_data.end_date.saturday? ? aggregate_meter.amr_data.end_date : aggregate_meter.amr_data.end_date.prev_occurring(:saturday)
        last_week_start_date = last_week_end_date.prev_occurring(:sunday)
        previous_week_end_date = last_week_start_date - 1
        previous_week_start_date = [aggregate_meter.amr_data.start_date, previous_week_end_date.prev_occurring(:sunday)].max

        last_week_date_range = last_week_start_date..last_week_end_date
        previous_week_date_range = previous_week_start_date..previous_week_end_date

        # Do last and previous weeks comprise two full weeks (7 days) of data?
        comparable = (last_week_start_date..last_week_end_date).count == 7 && (previous_week_start_date..previous_week_end_date).count == 7

        {
          last_week: last_week_date_range,
          previous_week: previous_week_date_range,
          comparable?: comparable
        }
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
