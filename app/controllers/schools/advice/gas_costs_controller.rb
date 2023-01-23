module Schools
  module Advice
    class GasCostsController < AdviceController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_costs
      end
    end
  end
end
