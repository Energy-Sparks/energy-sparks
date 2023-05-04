module Schools
  module Advice
    class RecentChangesService
      include AnalysableMixin

      def initialize(school:, meter_collection:, fuel_type:)
        @school = school
        @meter_collection = meter_collection
        @fuel_type = fuel_type
      end

      def recent_usage
        build_recent_usage
      end

      def enough_data?
        return false unless full_last_week?

        true
      end

      def data_available_from
        meter_data_checker.date_when_enough_data_available(14)
      end

      private

      def full_last_week?
        (last_week_date_range.first..last_week_date_range.last).count == 7
      end

      def full_previous_week?
        (previous_week_date_range.first..previous_week_date_range.last).count == 7
      end

      def build_recent_usage
        OpenStruct.new(
          last_week: last_week,
          previous_week: previous_week,
          change: change
        )
      end

      def change
        return nil unless full_previous_week?
        Usage::CombinedUsageMetricComparison.new(
          last_week.combined_usage_metric,
          previous_week.combined_usage_metric
        ).compare
      end

      def last_week
        @last_week ||= usage_data_for(last_week_date_range)
      end

      def previous_week
        return nil unless full_previous_week?
        @previous_week ||= usage_data_for(previous_week_date_range)
      end

      def last_week_date_range
        @last_week_date_range ||= find_last_week_date_range
      end

      def find_last_week_date_range
        last_week_end_date = aggregate_meter.amr_data.end_date.saturday? ? aggregate_meter.amr_data.end_date : aggregate_meter.amr_data.end_date.prev_occurring(:saturday)
        last_week_start_date = last_week_end_date.prev_occurring(:sunday)
        [
          last_week_start_date,
          last_week_end_date
        ]
      end

      def previous_week_date_range
        previous_week_end_date = last_week_date_range.first - 1
        previous_week_start_date = [aggregate_meter.amr_data.start_date, previous_week_end_date.prev_occurring(:sunday)].max
        [
          previous_week_start_date,
          previous_week_end_date
        ]
      end

      def usage_data_for(date_range)
        OpenStruct.new(
          date_range: date_range,
          combined_usage_metric: build_combined_usage_metric_for(date_range)
        )
      end

      def build_combined_usage_metric_for(date_range)
        CombinedUsageMetric.new(
          kwh: aggregate_meter.amr_data.kwh_date_range(date_range.first, date_range.last, :kwh),
          £: aggregate_meter.amr_data.kwh_date_range(date_range.first, date_range.last, :£),
          co2: aggregate_meter.amr_data.kwh_date_range(date_range.first, date_range.last, :co2)
        )
      end

      def asof_date
        @asof_date ||= AggregateSchoolService.analysis_date(@meter_collection, @fuel_type)
      end

      def aggregate_meter
        @meter_collection.aggregate_meter(@fuel_type)
      end

      def meter_data_checker
        @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, asof_date)
      end
    end
  end
end
