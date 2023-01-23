module Schools
  module Advice
    class ElectricityIntradayController < AdviceController
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
