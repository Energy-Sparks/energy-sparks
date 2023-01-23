module Schools
  module Advice
    class HotWaterController < AdviceController
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
