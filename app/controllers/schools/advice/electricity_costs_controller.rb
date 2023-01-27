module Schools
  module Advice
    class ElectricityCostsController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_costs
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
