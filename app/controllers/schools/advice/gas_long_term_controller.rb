module Schools
  module Advice
    class GasLongTermController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_gas_long_term_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_long_term
      end
    end
  end
end
