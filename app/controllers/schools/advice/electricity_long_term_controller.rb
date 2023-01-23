module Schools
  module Advice
    class ElectricityLongTermController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_electricity_long_term_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_long_term
      end
    end
  end
end
