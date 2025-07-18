module Schools
  module Advice
    class RecentChangesService
      include AnalysableMixin

      def initialize(school:, aggregate_school_service:, fuel_type:)
        @school = school
        @aggregate_school_service = aggregate_school_service
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
        return if full_last_week?

        last_week_date_range.last.next_occurring(:sunday) + 1.week
      end

      private

      def full_last_week?
        (last_week_date_range.first..last_week_date_range.last).count == 7
      end

      def full_previous_week?
        return false unless full_last_week?
        return false unless previous_week_date_range.any?
        return false unless aggregate_meter.amr_data.start_date <= previous_week_date_range.first

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
        last_week_start_date = [aggregate_meter.amr_data.start_date, last_week_end_date.prev_occurring(:sunday)].max
        [
          last_week_start_date,
          last_week_end_date
        ]
      end

      def previous_week_date_range
        return [] if aggregate_meter.amr_data.start_date >= last_week_date_range.first

        previous_week_end_date = last_week_date_range.first - 1
        previous_week_start_date = [aggregate_meter.amr_data.start_date, previous_week_end_date.prev_occurring(:sunday)].min
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

      def aggregate_meter
        meter_collection.aggregate_meter(@fuel_type)
      end

      def meter_collection
        @aggregate_school_service.meter_collection
      end
    end
  end
end
