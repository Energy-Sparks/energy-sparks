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

      def meters
        @meters ||= aggregate_school.heat_meters.select { |meter| meter.fuel_type == :gas }
      end
    end
  end
end
