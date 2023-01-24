module Schools
  module Advice
    class GasLongTermController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_long_term
      end
    end
  end
end
