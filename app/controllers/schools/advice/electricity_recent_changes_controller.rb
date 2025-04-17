module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      before_action :load_dashboard_alerts, only: %i[insights]

      def insights
        @recent_usage = recent_changes_service.recent_usage
      end

      def analysis
        @meters = @school.filterable_meters(:electricity)
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
          fuel_type: :electricity
        )
      end

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
