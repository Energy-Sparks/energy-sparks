module Schools
  module Advice
    class GasCostsController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_gas_costs_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :gas_costs
      end
    end
  end
end
