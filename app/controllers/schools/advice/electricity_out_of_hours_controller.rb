module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceBaseController
      include AdvicePages

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
