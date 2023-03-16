module Schools
  module Advice
    class BaseOutOfHoursController < AdviceBaseController
      before_action :set_usage_categories

      def insights
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @benchmarked_usage = benchmark_school(@annual_usage_breakdown)
      end

      def analysis
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @analysis_dates = analysis_dates
      end

      private

      def create_analysable
        annual_usage_breakdown_service
      end

      def analysis_dates
        start_date = aggregate_meter.amr_data.start_date
        end_date = aggregate_meter.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_years_data: one_years_data?(start_date, end_date),
          recent_data: recent_data?(end_date),
          months_analysed: months_analysed(start_date, end_date)
        )
      end

      def benchmark_school(annual_usage_breakdown)
        Schools::Comparison.new(
          school_value: annual_usage_breakdown&.out_of_hours&.kwh,
          benchmark_value: nil,
          exemplar_value: annual_usage_breakdown&.potential_savings(versus: :exemplar_school)&.kwh,
          unit: :kwh
        )
      end

      def annual_usage_breakdown_service
        ::Usage::AnnualUsageBreakdownService.new(
          meter_collection: aggregate_school,
          fuel_type: fuel_type
        )
      end

      def set_usage_categories
        @usage_categories = [:holiday, :weekend, :school_day_open, :school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end
    end
  end
end
