module Schools
  module Advice
    class TotalEnergyUseController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_total_energy_use_path(@school)
      end

      def insights
      end

      def analysis
      end

      private

      def advice_page_key
        :total_energy_use
      end
    end
  end
end
