module Schools
  module Advice
    class ElectricityIntradayController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_electricity_intraday_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
