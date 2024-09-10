module Schools
  module Advice
    class BaseOutOfHoursController < AdviceBaseController
      before_action :set_usage_categories

      def insights
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @benchmarked_usage = benchmark_school(@annual_usage_breakdown)
        unless @analysis_dates.one_years_data?
          @well_managed_percent = benchmark_value(:benchmark_school)
        end
      end

      def analysis
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @holiday_usage = holiday_usage_calculation_service.school_holiday_calendar_comparison
        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school, advice_page_fuel_type, date_window: 363)
      end

      private

      def check_can_run_analysis
        @analysable = create_analysable
        render 'not_enough_data' and return unless @analysable.enough_data?
        @analysis_dates = analysis_dates
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        render 'schools/advice/out_of_hours/no_usage' and return if @annual_usage_breakdown&.out_of_hours&.kwh&.zero?
      end

      def aggregate_meter
        aggregate_school.aggregate_meter(advice_page_fuel_type)
      end

      def create_analysable
        annual_usage_breakdown_service
      end

      # for charts that use the last full week
      # beginning of the week is Sunday
      def last_full_week_start_date(end_date)
        (end_date - 13.months).beginning_of_week - 1
      end

      def analysis_dates
        dates = super
        dates.date_when_one_years_data = Util::MeterDateRangeChecker.new(aggregate_meter).date_when_one_years_data
        dates
      end

      def benchmark_school(annual_usage_breakdown)
        Schools::Comparison.new(
          school_value: annual_usage_breakdown.out_of_hours.kwh,
          benchmark_value: (annual_usage_breakdown.total.kwh * benchmark_value(:benchmark_school)),
          exemplar_value: (annual_usage_breakdown.total.kwh * benchmark_value(:exemplar_school)),
          unit: :kwh
        )
      end

      def annual_usage_breakdown_service
        ::Usage::UsageBreakdownService.new(
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

      def benchmark_value(comparison)
        Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator.benchmark(compare: comparison, fuel_type: fuel_type)
      end

      def set_usage_categories
        @usage_categories = [:holiday, :weekend, :school_day_open, :school_day_closed]
        @usage_categories += [:community] if @school.school_times.community_use.any?
        @usage_categories
      end
    end
  end
end
