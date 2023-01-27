module Schools
  module Advice
    class GasLongTermController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_long_term
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
