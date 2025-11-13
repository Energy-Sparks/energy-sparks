module Schools
  module Advice
    class BaseLongTermController < AdviceBaseController
      def insights
        @benchmarked_usage = usage_service.benchmark_usage
        set_consumption_by_month
      end

      def analysis
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)

        @estimated_savings_vs_exemplar = usage_service.estimated_savings(versus: :exemplar_school)
        @estimated_savings_vs_benchmark = usage_service.estimated_savings(versus: :benchmark_school)

        @meter_selection =
          Charts::MeterSelection.new(@school, aggregate_school_service, advice_page_fuel_type, date_window: 363)
        set_consumption_by_month
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

      def set_consumption_by_month
        @consumption_by_month = Schools::Advice::ConsumptionByMonthService
                                .consumption_by_month(aggregate_school.aggregate_meter(fuel_type), @school)
      end
    end
  end
end
