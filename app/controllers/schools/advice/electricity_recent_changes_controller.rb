module Schools
  module Advice
    class ElectricityRecentChangesController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_recent_changes
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
