module Schools
  module Advice
    class GasLongTermController < AdviceBaseController
      include LongTermUsage

      def insights
        @analysis_dates = analysis_dates
        @annual_usage = usage_service.annual_usage
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)
        @annual_usage_change_since_last_year = usage_service.annual_usage_change_since_last_year
        @benchmarked_usage = benchmarked_usage(@annual_usage.kwh)
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

      def advice_page_key
        :gas_long_term
      end

      def fuel_type
        :gas
      end

      def aggregate_meter
        aggregate_school.aggregated_heat_meters
      end
    end
  end
end
