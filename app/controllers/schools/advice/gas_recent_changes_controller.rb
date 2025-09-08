module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      before_action :load_dashboard_alerts

      def insights
        @recent_usage = recent_changes_service.recent_usage
      end

      def analysis
        @meters = @school.filterable_meters(:gas)
        @chart_config = @analysis_dates.usage_chart_dates
      end

      private

      def create_analysable
        recent_changes_service
      end

      def recent_changes_service
        @recent_changes_service ||= Schools::Advice::RecentChangesService.new(
          school: @school,
          aggregate_school_service: aggregate_school_service,
          fuel_type: :gas
        )
      end

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
