module Schools
  module Advice
    class ElectricityCostsController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_electricity_costs_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :electricity_costs
      end
    end
  end
end
