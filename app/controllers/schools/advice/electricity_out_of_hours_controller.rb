module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceBaseController
      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_out_of_hours
      end

      def advice_page_fuel_type
        :electricity
      end
    end
  end
end
