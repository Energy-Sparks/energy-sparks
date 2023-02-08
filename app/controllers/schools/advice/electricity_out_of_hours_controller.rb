module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceBaseController
      def insights
      end

      def analysis
        @usage_categories = set_usage_categories
        @annual_usage_breakdown = ::Usage::AnnualUsageBreakdownService.new(meter_collection: aggregate_school, fuel_type: :electricity).usage_breakdown
      end

      private

      def set_usage_categories
        usage_categories = [:holidays, :weekends, :school_day_open, :school_day_closed]
        usage_categories += [:community] if @school.school_times.community_use.any?
        usage_categories
      end

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
