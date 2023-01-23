module Schools
  module Advice
    class GasIntradayController < AdviceController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_intraday
      end
    end
  end
end
