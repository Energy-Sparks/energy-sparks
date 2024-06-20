module Schools
  module Advice
    class GasMeterBreakdownController < AdviceBaseController
      private

      def fuel_type
        :gas
      end

      def advice_page_key
        :gas_meter_breakdown
      end
    end
  end
end
