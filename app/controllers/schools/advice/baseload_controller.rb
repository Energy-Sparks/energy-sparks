module Schools
  module Advice
    class BaseloadController < AdviceController
      def show
        redirect_to insights_school_advice_baseload_path(@school)
      end

      def insights
      end

      def analysis
        baseload_service = Baseload::BaseloadCalculationService.new(aggregate_school.aggregated_electricity_meters)
        @baseload_usage = baseload_service.annual_baseload_usage

        benchmark_service = Baseload::BaseloadBenchmarkingService.new(aggregate_school)
        @benchmark_usage = benchmark_service.baseload_usage
        @estimated_savings = benchmark_service.estimated_savings

        @chart_name = :baseload_lastyear
        @multiple_meters = @school.meters.electricity.count > 1
      end

      private

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end
