module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @analysis_dates = analysis_dates
        @recent_usage = build_recent_usage
      end

      def analysis
        @meters = @school.filterable_meters.electricity
        @chart_config = start_end_dates
      end

      private

      def create_analysable
        electricity_recent_changes_service
      end

      def electricity_recent_changes_service
        @electricity_recent_changes_service ||= Schools::Advice::ElectricityRecentChangesService.new(@school, aggregate_school)
      end

      def build_recent_usage
        OpenStruct.new(
          last_week: last_week,
          previous_week: previous_week,
          change: change
        )
      end

      def change
        return nil unless electricity_recent_changes_service.date_ranges[:comparable?]
        Usage::CombinedUsageMetricComparison.new(
          previous_week.combined_usage_metric,
          last_week.combined_usage_metric
        ).compare
      end

      def last_week
        timescale = { daterange: electricity_recent_changes_service.date_ranges[:last_week] }
        @last_week ||= recent_usage_calculation.recent_usage(timescale)
      end

      def previous_week
        timescale = { daterange: electricity_recent_changes_service.date_ranges[:previous_week] }
        @previous_week ||= recent_usage_calculation.recent_usage(timescale)
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
