module Schools
  module Advice
    class GasIntradayController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_gas_intraday_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_intraday
      end
    end
  end
end
