module Schools
  module Advice
    class ElectricityOutOfHoursController < AdviceBaseController
      before_action :set_annual_usage_breakdown
      before_action :set_usage_categories

      def insights
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def analysis_dates
        start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_years_data: one_years_data?(start_date, end_date),
          recent_data: recent_data?(end_date),
          months_analysed: months_analysed(start_date, end_date)
        )
      end

      def set_annual_usage_breakdown
        @annual_usage_breakdown = ::Usage::AnnualUsageBreakdownService.new(
          meter_collection: aggregate_school,
          fuel_type: :electricity
        ).usage_breakdown
      end

      def set_usage_categories
        @usage_categories = [:holiday, :weekend, :school_day_open, :school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end

      def advice_page_key
        :electricity_out_of_hours
      end
    end
  end
end
