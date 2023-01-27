module Schools
  module Advice
    class GasOutOfHoursController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_out_of_hours
      end

      def advice_page_fuel_type
        :gas
      end
    end
  end
end
