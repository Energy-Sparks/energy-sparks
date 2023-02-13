module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      def insights
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
