module Schools
  module Advice
    class GasCostsController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_costs
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
