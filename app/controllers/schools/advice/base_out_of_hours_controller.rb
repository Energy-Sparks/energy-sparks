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
        @holiday_usage = holiday_usage_calculation_service.school_holiday_calendar_comparison
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
          months_of_data: months_between(start_date, end_date),
          last_full_week_start_date: last_full_week_start_date(end_date),
          last_full_week_end_date: last_full_week_end_date(end_date)
        )
      end

      # for charts that use the last full week
      # beginning of the week is Sunday
      def last_full_week_start_date(end_date)
        (end_date - 13.months).beginning_of_week - 1
      end

      # for charts that use the last full week
      # end of the week is Saturday
      def last_full_week_end_date(end_date)
        end_date.prev_week.end_of_week - 1
      end

      def benchmark_school(annual_usage_breakdown)
        Schools::Comparison.new(
          school_value: annual_usage_breakdown.out_of_hours.kwh,
          benchmark_value: (annual_usage_breakdown.total.kwh * BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY),
          exemplar_value: (annual_usage_breakdown.total.kwh * BenchmarkMetrics::EXEMPLAR_OUT_OF_HOURS_USE_PERCENT_ELECTRICITY),
          unit: :kwh
        )
      end

      def annual_usage_breakdown_service
        ::Usage::AnnualUsageBreakdownService.new(
          meter_collection: aggregate_school,
          fuel_type: fuel_type
        )
      end

      def holiday_usage_calculation_service
        ::Usage::HolidayUsageCalculationService.new(
          aggregate_meter,
          aggregate_school.holidays
        )
      end

      def set_usage_categories
        @usage_categories = %i[holiday weekend school_day_open school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end
    end
  end
end
