module Schools
  module Advice
    class ElectricityLongTermController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_long_term
      end
    end
  end
end
