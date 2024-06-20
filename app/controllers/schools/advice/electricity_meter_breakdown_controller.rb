module Schools
  module Advice
    class ElectricityMeterBreakdownController < BaseMeterBreakdownController
      private

      def fuel_type
        :electricity
      end

      def advice_page_key
        :electricity_meter_breakdown
      end
    end
  end
end
