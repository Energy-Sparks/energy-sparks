module Schools
  module Advice
    class GasMeterBreakdownController < BaseMeterBreakdownController
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
