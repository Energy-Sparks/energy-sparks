module Schools
  module Advice
    class ThermostaticControlController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :thermostatic_control
      end
    end
  end
end
