module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      def insights
        @recent_usage = build_recent_usage
      end

      def analysis
        @meters = @school.filterable_meters.electricity
        @chart_config = start_end_dates
      end

      private

      def create_analysable
        OpenStruct.new(
          enough_data?: two_weeks_data?
        )
      end

      def two_weeks_data?
        helpers.two_weeks_data?(
          start_date: aggregate_school.aggregated_electricity_meters.amr_data.start_date,
          end_date: aggregate_school.aggregated_electricity_meters.amr_data.end_date
        )
      end

      def build_recent_usage
        OpenStruct.new(
          last_week: last_week,
          previous_week: previous_week,
          change: change
        )
      end

      def change
        Usage::CombinedUsageMetricComparison.new(
          previous_week.combined_usage_metric,
          last_week.combined_usage_metric
        ).compare
      end

      def last_week
        @last_week ||= recent_usage_calculation.recent_usage(period_range: 0..0)
      end

      def previous_week
        @previous_week ||= recent_usage_calculation.recent_usage(period_range: -1..-1)
      end

      def recent_usage_calculation
        @recent_usage_calculation ||= Usage::RecentUsagePeriodCalculationService.new(
          meter_collection: aggregate_school,
          fuel_type: :electricity
        )
      end

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
