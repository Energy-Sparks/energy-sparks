module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      before_action :load_dashboard_alerts, only: [:insights]

      def insights
        @analysis_dates = analysis_dates
        peak_usage_service = Schools::Advice::PeakUsageService.new(@school, aggregate_school)
        if peak_usage_service.enough_data?
          @average_peak_kw = peak_usage_service.average_peak_kw
          @peak_kw_usage_percentage_change = peak_usage_service.percentage_change_in_peak_kw
          @benchmarked_usage = peak_usage_service.benchmark_peak_usage
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
        # page irrespective of amount of data available.
        # Some insights page sections will be hidden when not relevant.  See:
        # https://trello.com/c/UOlSVWAg/3144-analysis-page-feedback-electricity-intraday
        OpenStruct.new(
          enough_data?: true
        )
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end
