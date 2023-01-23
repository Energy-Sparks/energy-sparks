module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
