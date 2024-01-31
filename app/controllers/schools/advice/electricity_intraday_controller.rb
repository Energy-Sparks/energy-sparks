module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @analysis_dates = analysis_dates
        if peak_usage_service.enough_data?
          @average_peak_kw = average_peak_kw
          @peak_kw_usage_percentage_change = percentage_change_in_peak_kw
          @benchmarked_usage = benchmark_peak_usage
          @peak_usage_service_date_range = peak_usage_service.date_range
        else
          @not_enough_data_data_available_from = peak_usage_service.data_available_from
        end
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def create_analysable
        # We still need to show parts of the analysis and insights
        # page irrespective of ammount of data available.
        # Some insights page sections will be hidden when not relevent.  See:
        # https://trello.com/c/UOlSVWAg/3144-analysis-page-feedback-electricity-intraday
        OpenStruct.new(
          enough_data?: true
        )
      end

      def asof_date
        peak_usage_service.asof_date
      end

      def benchmark_peak_usage
        peak_usage_service.benchmark_peak_usage
      end

      def percentage_change_in_peak_kw
        peak_usage_service.percentage_change_in_peak_kw
      end

      def average_peak_kw
        peak_usage_service.average_peak_kw
      end

      def peak_usage_service
        @peak_usage_service = Schools::Advice::PeakUsageService.new(@school, aggregate_school)
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
