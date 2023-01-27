module Schools
  module Advice
    class SolarPvController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :solar_pv
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
