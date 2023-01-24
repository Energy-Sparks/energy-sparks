module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_costs
      end
    end
  end
end
