module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @analysis_dates = analysis_dates
        @recent_usage = recent_changes_service.recent_usage
      end

      def analysis
        @meters = @school.filterable_meters.gas
        @chart_config = start_end_dates
      end

      private

      def create_analysable
        recent_changes_service
      end

      def recent_changes_service
        @recent_changes_service ||= Schools::Advice::RecentChangesService.new(
          school: @school,
          meter_collection: aggregate_school,
          fuel_type: :gas
        )
      end

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
