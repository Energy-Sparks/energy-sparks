module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceBaseController
      def insights
      end

      def analysis
        @annual_usage_breakdown = ::Usage::AnnualUsageBreakdownService.new(meter_collection: aggregate_school, fuel_type: :electricity).usage_breakdown
      end

      private

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
