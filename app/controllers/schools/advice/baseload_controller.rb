module Schools
  module Advice
    class BaseloadController < AdviceController
      before_action :load_advice_page, only: [:insights, :analysis, :learn_more]
      before_action :check_authorisation, only: [:insights, :analysis, :learn_more]

      def show
        redirect_to insights_school_advice_baseload_path(@school)
      end

      def insights
      end

      def analysis
        @tab = 'analysis'
        service = Baseload::BaseloadBenchmarkingService.new(aggregate_school)
        @estimated_savings = service.estimated_savings(versus: :benchmark_school)
        @chart_name = :baseload_lastyear
        @chart_config = ChartManager.build_chart_config(ChartManager::STANDARD_CHART_CONFIGURATION[@chart_name])
      end

      def learn_more
        @content = @advice_page.learn_more
      end

      private

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end
