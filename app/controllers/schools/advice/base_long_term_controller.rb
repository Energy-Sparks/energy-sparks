module Schools
  module Advice
    class BaseLongTermController < AdviceBaseController
      def insights
        @annual_usage = usage_service.annual_usage
        @annual_usage_change_since_last_year = usage_service.annual_usage_change_since_last_year
        @benchmarked_usage = usage_service.benchmark_usage
      end

      def analysis
        @annual_usage = usage_service.annual_usage
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)

        @estimated_savings_vs_exemplar = usage_service.estimated_savings(versus: :exemplar_school)
        @estimated_savings_vs_benchmark = usage_service.estimated_savings(versus: :benchmark_school)

        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school_service, advice_page_fuel_type, date_window: 363)
      end

      private

      def multiple_meters?
        @school.meters.active.where(meter_type: fuel_type).count > 1
      end

      def create_analysable
        usage_service
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school_service, fuel_type)
      end
    end
  end
end
