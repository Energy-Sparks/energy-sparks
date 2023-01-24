module Schools
  module Advice
    class TotalEnergyUseController < AdviceBaseController
      include AdvicePages

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
