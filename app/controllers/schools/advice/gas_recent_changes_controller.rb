module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      def insights
      end

      def analysis
        @meters = @school.filterable_meters.gas
        @chart_config = start_end_dates
      end

      private

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
