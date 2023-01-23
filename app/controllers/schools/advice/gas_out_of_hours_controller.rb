module Schools
  module Advice
    class GasOutOfHoursController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_out_of_hours
      end
    end
  end
end
