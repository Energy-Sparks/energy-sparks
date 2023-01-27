module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_recent_changes
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
