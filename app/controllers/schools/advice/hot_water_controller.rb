module Schools
  module Advice
    class HotWaterController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :hot_water
      end
    end
  end
end
