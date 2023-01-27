module Schools
  module Advice
    class ThermostaticControlController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :thermostatic_control
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
