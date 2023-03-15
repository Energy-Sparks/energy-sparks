module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      def insights
        @average_peak_kw = peak_usage_service.average_peak_kw
        @peak_kw_usage_percentage_change = peak_usage_service.percentage_change_in_peak_kw
        @benchmarked_usage = peak_usage_service.benchmark_peak_usage
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def peak_usage_service
        @peak_usage_service = Schools::Advice::PeakUsageService.new(@school, aggregate_school)
      end

      def create_analysable
        peak_usage_service
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
