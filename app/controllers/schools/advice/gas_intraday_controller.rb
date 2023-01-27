module Schools
  module Advice
    class GasIntradayController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_intraday
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
