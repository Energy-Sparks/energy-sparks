module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      def insights
        @recent_usage = ::Usage::RecentUsageComparisonService.new(
          meter_collection: aggregate_school,
          fuel_type: :electricity
          ).recent_usage
      end

      def analysis
        @meters = @school.filterable_meters.electricity
        @chart_config = start_end_dates
      end

      private

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
