module Schools
  module Advice
    class GasLongTermController < BaseLongTermController
      private

      def fuel_type
        :gas
      end

      def advice_page_key
        :gas_long_term
      end

      def aggregate_meter
        aggregate_school.aggregated_heat_meters
      end
    end
  end
end
