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

      def meters
        @meters ||= aggregate_school.electricity_meters.select { |meter| meter.fuel_type == :electricity }
      end
    end
  end
end
