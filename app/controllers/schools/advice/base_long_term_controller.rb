module Schools
  module Advice
    class BaseLongTermController < AdviceBaseController
      def insights
        @analysis_dates = analysis_dates
        @annual_usage = usage_service.annual_usage
        @annual_usage_change_since_last_year = usage_service.annual_usage_change_since_last_year
        @benchmarked_usage = usage_service.benchmark_usage
      end

      def analysis
        @analysis_dates = analysis_dates

        @annual_usage = usage_service.annual_usage
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)

        @estimated_savings_vs_exemplar = usage_service.estimated_savings(versus: :exemplar_school)
        @estimated_savings_vs_benchmark = usage_service.estimated_savings(versus: :benchmark_school)

        @multiple_meters = multiple_meters?
        if @multiple_meters
          @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
          @meters_for_breakdown = sorted_meters_for_breakdown(@annual_usage_meter_breakdown)
        end
      end

      private

      def multiple_meters?
        @school.meters.active.where(meter_type: fuel_type).count > 1
      end

      def create_analysable
        usage_service
      end

      def sorted_meters_for_breakdown(annual_usage_meter_breakdown)
        meters = @school.meters.where(mpan_mprn: annual_usage_meter_breakdown.meters).order(:name, :mpan_mprn)
        meters.index_by(&:mpan_mprn)
      end

      def analysis_dates
        start_date = aggregate_meter.amr_data.start_date
        end_date = aggregate_meter.amr_data.end_date
        OpenStruct.new(
          start_date: start_date,
          end_date: end_date,
          one_year_before_end: end_date - 1.year,
          last_full_week_start_date: last_full_week_start_date(end_date),
          last_full_week_end_date: last_full_week_end_date(end_date),
          one_years_data: one_years_data?(start_date, end_date),
          months_of_data: months_between(start_date, end_date),
          recent_data: recent_data?(end_date)
        )
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
      end
    end
  end
end
