module Schools
  module Advice
    class ElectricityLongTermController < AdviceBaseController
      def insights
      end

      def analysis
        @analysis_dates = analysis_dates

        @annual_usage = usage_service.annual_usage
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)

        @estimated_savings_vs_exemplar = usage_service.estimated_savings(versus: :exemplar_school)
        @estimated_savings_vs_benchmark = usage_service.estimated_savings(versus: :benchmark_school)

        @multiple_meters = @school.meters.electricity.count > 1
        if @multiple_meters
          @annual_usage_meter_breakdown = usage_service.annual_usage_meter_breakdown
          @meters_for_breakdown = sorted_meters_for_breakdown(@annual_usage_meter_breakdown)
        end
      end

      private

      def advice_page_key
        :electricity_long_term
      end

      def create_analysable
        usage_service
      end

      def sorted_meters_for_breakdown(annual_usage_meter_breakdown)
        meters = {}
        annual_usage_meter_breakdown.meters.each do |mpan_mprn|
          meters[mpan_mprn] = @school.meters.find_by_mpan_mprn(mpan_mprn)
        end
        meters.sort { |a, b| a[1].name_or_mpan_mprn <=> b[1].name_or_mpan_mprn }
      end

      def analysis_dates
        start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
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

      #for charts that use the last full week
      def last_full_week_start_date(end_date)
        return end_date.prev_year.end_of_week
      end

      #for charts that use the last full week
      def last_full_week_end_date(end_date)
        return end_date.prev_week.end_of_week - 1
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school, :electricity)
      end
    end
  end
end
