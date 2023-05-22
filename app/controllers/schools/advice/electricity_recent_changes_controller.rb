module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @analysis_dates = analysis_dates
        @recent_usage = recent_changes_service.recent_usage
      end

      def analysis
        @meters = @school.filterable_meters.electricity
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
          fuel_type: :electricity
        )
      end

      def advice_page_key
        :electricity_recent_changes
      end
    end
  end
end
