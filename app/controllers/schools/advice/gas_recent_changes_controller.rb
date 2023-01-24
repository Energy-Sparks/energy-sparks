module Schools
  module Advice
    class GasRecentChangesController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_recent_changes
      end
    end
  end
end
