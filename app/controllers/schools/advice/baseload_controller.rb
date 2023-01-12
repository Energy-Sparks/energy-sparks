module Schools
  module Advice
    class BaseloadController < AdviceController
      before_action :load_advice_page, only: [:insights, :analysis, :learn_more]
      before_action :check_authorisation, only: [:insights, :analysis, :learn_more]

      def show
        redirect_to insights_school_advice_baseload_path(@school)
      end

      def insights
        @tab = :insights
        render :page
      end

      def analysis
        baseload_service = Baseload::BaseloadCalculationService.new(aggregate_school.aggregated_electricity_meters)
        @baseload_usage = baseload_service.annual_baseload_usage

        benchmark_service = Baseload::BaseloadBenchmarkingService.new(aggregate_school)
        @benchmark_usage = benchmark_service.baseload_usage
        @estimated_savings = benchmark_service.estimated_savings

        @chart_name = :baseload_lastyear

        @tab = :analysis
        render :page
      end

      def learn_more
        @content = @advice_page.learn_more

        @tab = :learn_more
        render :page
      end

      private

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end
