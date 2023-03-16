module Schools
  module Advice
    class GasOutOfHoursController < BaseOutOfHoursController
      private

      def fuel_type
        :gas
      end

      def advice_page_key
        :gas_out_of_hours
      end

      def aggregate_meter
        aggregate_school.aggregated_heat_meters
      end
    end
  end
end
