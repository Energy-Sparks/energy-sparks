module Schools
  module Advice
    class BoilerControlController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :boiler_control
      end
    end
  end
end
