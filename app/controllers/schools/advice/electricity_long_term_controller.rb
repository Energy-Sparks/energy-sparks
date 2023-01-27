module Schools
  module Advice
    class ElectricityLongTermController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_long_term
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
