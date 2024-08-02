module Schools
  module Advice
    class BaseOutOfHoursController < AdviceBaseController
      before_action :set_usage_categories

      def insights
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @benchmarked_usage = benchmark_school(@annual_usage_breakdown)
        @analysis_dates = analysis_dates
        unless @analysis_dates.one_years_data?
          @well_managed_percent = benchmark_value(:benchmark_school)
        end
      end

      def analysis
        @annual_usage_breakdown = annual_usage_breakdown_service.usage_breakdown
        @holiday_usage = holiday_usage_calculation_service.school_holiday_calendar_comparison
        @analysis_dates = analysis_dates
        @meters = options_for_meter_select
        @date_ranges_by_meter = date_ranges_by_meter
      end

      private

      def aggregate_meter
        aggregate_school.aggregate_meter(advice_page_fuel_type)
      end

      # TODO
      def aggregate_meter_label
        I18n.t('advice_pages.electricity_costs.analysis.meter_breakdown.whole_school')
      end

      def aggregate_meter_mpan_mprn
        aggregate_meter.mpan_mprn.to_s
      end

      def aggregate_meter_adapter
        OpenStruct.new(mpan_mprn: aggregate_meter_mpan_mprn, display_name: aggregate_meter_label, has_readings?: true)
      end

      def options_for_meter_select
        [aggregate_meter_adapter] + @school.meters.active.where(meter_type: advice_page_fuel_type).order(:mpan_mprn)
      end

      def date_ranges_by_meter
        ranges_by_meter = aggregate_school.electricity_meters.each_with_object({}) do |analytics_meter, date_range_by_meter|
          end_date = analytics_meter.amr_data.end_date
          start_date = [end_date - 363, analytics_meter.amr_data.start_date].max
          meter = @school.meters.find_by_mpan_mprn(analytics_meter.mpan_mprn)
          date_range_by_meter[analytics_meter.mpan_mprn] = {
            meter: meter,
            start_date: start_date,
            end_date: end_date
          }
        end
        ranges_by_meter[aggregate_meter_mpan_mprn] = {
          meter: nil,
          start_date: [aggregate_meter.amr_data.end_date - 365, aggregate_meter.amr_data.start_date].max,
          end_date: aggregate_meter.amr_data.end_date
        }
        ranges_by_meter
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
